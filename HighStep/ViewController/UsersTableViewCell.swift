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
    @IBAction func challenge(sender: UIButton) {
        
        let startDate = NSDate()
        let endDate = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitHour, value: 5, toDate: startDate, options: nil)
        
//        HealthKitManager.queryStepsFromDate(startDate, toDate: endDate!) {(steps: Double) in
        
//            println("next 5 minutes  steps for: \(PFUser.currentUser())")
        
            if let curUser = PFUser.currentUser(), userBeingChallenged = self.userBeingChallenged {
                var challenge = PFObject(className:"Challenge")
                challenge["fromUser"] = curUser
                challenge["stepCountFromUser"] = nil
                challenge["toUser"] = userBeingChallenged
                challenge["stepCountToUser"] = Int.random(1...4000)
                challenge["startDate"] = startDate
                challenge["endDate"] = endDate!
                challenge["toUserHasAccepted"] = false
                
                
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

//}

extension Int
{
    static func random(range: Range<Int> ) -> Int
    {
        var offset = 0
        
        if range.startIndex < 0   // allow negative ranges
        {
            offset = abs(range.startIndex)
        }
        
        let mini = UInt32(range.startIndex + offset)
        let maxi = UInt32(range.endIndex   + offset)
        
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
}
