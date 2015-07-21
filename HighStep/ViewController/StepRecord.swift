//
//  StepRecord.swift
//  HighStep
//
//  Created by Maverick on 7/21/15.
//  Copyright (c) 2015 Maverick. All rights reserved.
//

import Foundation
import Parse
import ConvenienceKit

class StepRecord : PFObject, PFSubclassing {
    
    @NSManaged var userName: PFUser?
    @NSManaged var stepCount: PFObject?
    @NSManaged var startDate: PFObject?
    @NSManaged var endDate: PFObject?

    
    //MARK: PFSubclassing Protocol
    
    static func parseClassName() -> String {
        return "StepRecord"
    }
    
    override init () {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
    
    
    
    
    
}