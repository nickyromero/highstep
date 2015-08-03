//
//  ChallengeTableViewCell.swift
//  HighStep
//
//  Created by Maverick on 7/21/15.
//  Copyright (c) 2015 Maverick. All rights reserved.
//

import UIKit
import Parse


class ChallengeTableViewCell: UITableViewCell {
 
   
    @IBOutlet weak var currentUser: UILabel!
    @IBOutlet weak var stepCountCurrentUser: UILabel!
    
    @IBOutlet weak var challengeUser: UILabel!
    @IBOutlet weak var stepCountChallengeUser: UILabel!
    
    @IBOutlet weak var endDate: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    
//    let formatter = NSDateFormatter()
//    formatter.timeStyle = NSDateFormatterStyle.ShortStyle
//    formatter.stringFromDate(startDate)
// 
   





}
    
//    
//    @IBAction func showSteps(sender: UIButton) {
//        let endDate = NSDate()
//        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitHour, value: -2, toDate: endDate, options: nil)
//
//        
//        let endDate = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitMinute, value: 5, toDate: startDate, options: nil)
//        
////let endDate = NSCalendar.dateByAddingComponents(.CalendarUnitMinute)
//    
//        HealthKitManager.queryStepsFromDate(self.startDate, toDate: endDate!) {
//            (steps: Double) in
//            
//            println("steps for five minutes starting \(self.startDate)")
//            self.totalSteps.text = "\(steps) since \(self.startDate)"
//            println(steps)
//        }
//
//     
//        
//    }
////
//    
//
//
//
