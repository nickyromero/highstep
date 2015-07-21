//
//  Challenge.swift
//  HighStep
//
//  Created by Maverick on 7/20/15.
//  Copyright (c) 2015 Maverick. All rights reserved.
//

import Foundation
import Parse
import ConvenienceKit


class Challenge : PFObject, PFSubclassing {

    @NSManaged var user: PFUser?

    
    //MARK: PFSubclassing Protocol
    
    static func parseClassName() -> String {
        return "Challenge"
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