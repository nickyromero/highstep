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
               
                /* Be careful, we are not on the UI thread */
                HealthKitManager.updateAllSteps()
                
                completionHandler()
        })
    }()
    
    
    static let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
        }()
    
    
    func setupHealthStoreIfPossible(completion: ((Bool, NSError!) -> Void)!) {
        
        
        let stepType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        
        let typeSet: NSMutableSet = NSMutableSet()
        typeSet.addObject(stepType)
        
        if HKHealthStore.isHealthDataAvailable()
        {
            HealthKitManager.healthStore?.requestAuthorizationToShareTypes(nil, readTypes: typeSet as Set<NSObject>, completion: { (success, error) -> Void in
                completion(success, error)
                HealthKitManager.healthStore?.executeQuery(HealthKitManager.query)
                HealthKitManager.healthStore?.enableBackgroundDeliveryForType(stepType,
                    frequency: .Immediate,
                    withCompletion: {succeeded, error in
                        
                        if succeeded{
                            print("Enabled background delivery of weight changes")
                        } else {
                            if let theError = error{
                                print("Failed to enable background delivery of weight changes. ")
                                print("Error = \(theError)")
                            }
                        }
                        
                })
                
            })
        }
    }
    
    static func updateAllSteps() {
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
                if let challenges = objects as? [PFObject] {
                    HealthKitManager.updateChallenge(challenges, withClosure: { (isDone, updatedChalls) -> (Void) in
                        PFObject.saveAllInBackground(challenges, block: nil)
                    })
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
                    } else {
                        
                        challenge["stepCountToUser"] = Int(steps)
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
