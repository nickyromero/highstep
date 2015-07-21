//
//  HealthKitManager.swift
//  HighStep
//
//  Created by Maverick on 7/20/15.
//  Copyright (c) 2015 Maverick. All rights reserved.
//

import Foundation
import HealthKit



class HealthKitManager: NSObject {
   
    
    let healthStore: HKHealthStore = HKHealthStore()
        override init(){
        super.init()
    }

    class func isHealthKitAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }


    func setupHealthStoreIfPossible(completion: ((Bool, NSError!) -> Void)!) {
        
        let stepType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        
        let distanceType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
        
        let typeSet: NSMutableSet = NSMutableSet()
        typeSet.addObject(stepType)
        typeSet.addObject(distanceType)

        if HealthKitManager.isHealthKitAvailable()
        {
            healthStore.requestAuthorizationToShareTypes(nil, readTypes: typeSet as Set<NSObject>, completion: { (success, error) -> Void in
                completion(success, error)
            })
        }
    }
  
    
    
}
