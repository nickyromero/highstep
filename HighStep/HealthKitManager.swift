//
//  HealthKitManager.swift
//  HighStep
//
//  Created by Maverick on 7/20/15.
//  Copyright (c) 2015 Maverick. All rights reserved.
//

import Foundation
import HealthKit
import Parse

typealias StepsQueryCallBack = (Double) -> ()


struct HealthKitManager {
    static let stepType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
    
    static var predicate: NSPredicate = {
        let now = NSDate()
        let yesterday =
        NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay,
            value: -1,
            toDate: now,
            options: .WrapComponents)
        
        return HKQuery.predicateForSamplesWithStartDate(yesterday,
            endDate: now,
            options: .StrictEndDate)
        }()
    
    static var query: HKObserverQuery = {
        return HKObserverQuery(sampleType: stepType,
            predicate: predicate,
            updateHandler: { (query, completionHandler, error) -> Void in
               println("update handler")
                completionHandler()

                /* Be careful, we are not on the UI thread */
//                HealthKitManager.updateAllSteps(completionHandler)
                
        })
    }()
    
    
//    static let healthStore: HKHealthStore? = {
//        if HKHealthStore.isHealthDataAvailable() {
//            println("Creating new health store")
//            return HKHealthStore()
//        } else {
//            println("No health store available to initialize")
//            return nil
//        }
//        }()
    
    static let healthStore : HKHealthStore? = HKHealthStore()
    
    static func isAuthorized() -> Bool {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let isAuthorized = defaults.objectForKey("Authorize") as? Bool where isAuthorized {
            return true
            
        } else {
            return false
        }
        
        
//        let stepType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        
//        let authorizationStatus = healthStore?.authorizationStatusForType(stepType)
//        if(authorizationStatus == HKAuthorizationStatus.SharingAuthorized) {
//            return true
//        } else {
//            return false
//        }
    }
    func setupHealthStoreIfPossible(completion: ((Bool, NSError!) -> Void)!) {
        
        
        let stepType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        
        let typeSet: NSMutableSet = NSMutableSet()
        typeSet.addObject(stepType)
        
        if HKHealthStore.isHealthDataAvailable()
        {
            HealthKitManager.healthStore?.requestAuthorizationToShareTypes(nil, readTypes: typeSet as Set<NSObject>, completion: { (success, error) -> Void in

                completion(success, error)

            })
        }
    }
    
    
    static func enableBackground() {
        println("Enable background 1")
        if(!HealthKitManager.isAuthorized()) { return }
        println("Enable background 2")
        let stepType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        
        HealthKitManager.healthStore?.executeQuery(HealthKitManager.query)
        HealthKitManager.healthStore?.enableBackgroundDeliveryForType(stepType,
            frequency: .Immediate,
            withCompletion: {succeeded, error in
                println("Enable background 3")
                if succeeded{
                    print("Enabled background delivery of step changes")
                } else {
                    if let theError = error{
                        print("Failed to enable background delivery of step changes. ")
                        print("Error = \(theError)")
                    }
                }
                
                
        })
    }
    
    
    
    static func updateAllSteps(completionHandler: HKObserverQueryCompletionHandler!) {
        println("updateAllSteps()")
        if let user = PFUser.currentUser() {
            var fromQuery = PFQuery(className: "Challenge")
            fromQuery.whereKey("fromUser", equalTo: user)
            let toQuery = PFQuery(className: "Challenge")
            toQuery.whereKey("toUser", equalTo: user)
            let query = PFQuery.orQueryWithSubqueries([fromQuery, toQuery])
            query.whereKey("endDate", greaterThanOrEqualTo: NSDate())
            query.includeKey("fromUser")
            query.includeKey("toUser")
            query.orderByDescending("endDate")
            query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error: NSError?) -> Void in
                println("Challenges query found")

                if let challenges = objects as? [PFObject] {
                    println("Challenges query found 2")
                    
                    HealthKitManager.updateChallenge(challenges, withClosure: { (isDone, updatedChalls) -> (Void) in
//                        PFObject.saveAllInBackground(challenges, block: nil)
                        PFObject.saveAllInBackground(challenges, block: { (success, error) -> Void in
                            if let error = error {
                                println("Error saving challenges:" + error.description)
                            } else {
                                println("Challenges saved succesfully")
                            }
                            completionHandler()
                        })
                    })
                } else {
                    println(error?.description)
                }
            }
        }
    }
    
    static func queryStepsFromDate(startDate: NSDate, toDate endDate: NSDate, callback: StepsQueryCallBack) {
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        let query = HKSampleQuery(sampleType: stepType, predicate: predicate, limit: 0, sortDescriptors: nil, resultsHandler: {
            (query, results, error) in
            if results == nil {
                println("There was an error running the query: \(error)")
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                var total:Double = 0
                for steps in results as! [HKQuantitySample]
                {
                    // add values to dailyAVG
                    total += steps.quantity.doubleValueForUnit(HKUnit.countUnit())
                }
                callback(total)
            }
        })
        
        self.healthStore?.executeQuery(query)
    }
    
    
    
    static func updateChallenge(updateChallenges: Array<PFObject>, withClosure: (isDone: Bool, updatedChalls: Array<PFObject>) -> (Void)) {
        
        var index = 0
        
        
        for challenge in updateChallenges {
            let startDate = challenge["startDate"] as! NSDate
            let endDate = challenge["endDate"] as! NSDate
            
            
           

            HealthKitManager.queryStepsFromDate(startDate, toDate: endDate, callback: { (steps: Double) -> () in
                println(steps)
                if let fromUser = challenge["fromUser"] as? PFUser {
                    if fromUser.objectId == PFUser.currentUser()?.objectId {
                        
                        challenge["stepCountFromUser"] = Int(steps)
                        challenge["fromUserUpdate"] = NSDate()
                        
                        
                    } else {
                        
                        challenge["stepCountToUser"] = Int(steps)
                        challenge["toUserUpdate"] = NSDate()

                    }
                }
                index++
                
                if index == updateChallenges.count {
                    // call closure
                    withClosure(isDone: true, updatedChalls: updateChallenges)
                }
            })
        }
        
    }
    
    
    
    
}
