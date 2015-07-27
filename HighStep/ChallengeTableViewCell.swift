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
 
   
    @IBOutlet weak var fromUser: UILabel!
    @IBOutlet weak var stepCountFromUser: UILabel!
    
    @IBOutlet weak var toUser: UILabel!
    @IBOutlet weak var stepCountToUser: UILabel!
    
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    
    
    
    
    
    
    
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
