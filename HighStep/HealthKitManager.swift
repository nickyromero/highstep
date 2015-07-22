//
//  HealthKitManager.swift
//  HighStep
//
//  Created by Maverick on 7/20/15.
//  Copyright (c) 2015 Maverick. All rights reserved.
//

import Foundation
import HealthKit

typealias StepsQueryCallBack = (Double) -> ()


struct HealthKitManager {
    static let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }()
    
    
    func setupHealthStoreIfPossible(completion: ((Bool, NSError!) -> Void)!) {
        
        let stepType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        
        let distanceType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
        
        let typeSet: NSMutableSet = NSMutableSet()
        typeSet.addObject(stepType)
        typeSet.addObject(distanceType)
        
        if HKHealthStore.isHealthDataAvailable()
        {
            HealthKitManager.healthStore?.requestAuthorizationToShareTypes(nil, readTypes: typeSet as Set<NSObject>, completion: { (success, error) -> Void in
                completion(success, error)
            })
        }
    }
    
    static func queryStepsFromDate(startDate: NSDate, toDate endDate: NSDate, callback: StepsQueryCallBack) {
        let stepType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
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
        
        healthStore?.executeQuery(query)
    }
    
    static func queryStepsFromPastDay(callback: StepsQueryCallBack) {
        let endDate = NSDate()
        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: -1, toDate: endDate, options: nil)
        
        HealthKitManager.queryStepsFromDate(startDate!, toDate: endDate, callback: callback)
    }
    
}
