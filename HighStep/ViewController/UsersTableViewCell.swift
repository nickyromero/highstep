//
//  UsersTableViewCell.swift
//  HighStep
//
//  Created by Maverick on 7/23/15.
//  Copyright (c) 2015 Maverick. All rights reserved.
//

import UIKit
import Parse
import HealthKit


class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var userNames: UILabel!
    var userBeingChallenged: PFObject?
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    
    //    MARK: ACTION
    @IBAction func Challenge(sender: UIButton) {
        
        let startDate = NSDate()
        let endDate = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitMinute, value: 5, toDate: startDate, options: nil)
        
        HealthKitManager.queryStepsFromDate(startDate, toDate: endDate!) {(steps: Double) in
            
            println("next 5 minutes  steps for: \(PFUser.currentUser())")
            println(steps)
            
            var challenge = PFObject(className:"Challenge")
            challenge["fromUser"] = PFUser.currentUser()
//            challenge["stepCountFromUser"] = nil
            challenge["toUser"] = self.userBeingChallenged
//            challenge["stepCountToUser"] = nil
            challenge["startDate"] = startDate
            challenge["endDate"] = endDate!
            
            challenge.saveInBackgroundWithBlock { (success, error) -> Void in
                if success {
                    println("saved")
                } else {
                    println("\(error)")
                }
            }
        }
        
    }
    



}
