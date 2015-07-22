//
//  ChallengesViewController.swift
//  HighStep
//
//  Created by Maverick on 7/17/15.
//  Copyright (c) 2015 Maverick. All rights reserved.
//

import UIKit
import Parse
import HealthKit

class ChallengesViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        let endDate = NSDate()
        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitHour, value: -2, toDate: endDate, options: nil)
        
        HealthKitManager.queryStepsFromDate(startDate!, toDate: endDate) {
            (steps: Double) in
            
            println("past 2 hours day steps:")

            println(steps)
        }
        
        
        HealthKitManager.queryStepsFromPastDay {
            (steps: Double) in
            
            println("past day steps:")
            println(steps)
//            self.totalSteps.text = "\(steps)"
            
            
    }
    
     func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
//    @IBOutlet weak var totalSteps: UILabel!
//    
//    
//    @IBAction func showSteps(sender: UIButton) {
//        
//        
//        
//            
//        }
    }

      
    
    @IBAction func addButtonTapped(sender: UIBarButtonItem) {
        
        var steps = PFObject(className: "StepRecord")
        steps["stepCount"] = 12
        steps["userName"] = PFUser.currentUser()
        steps["startDate"] = NSDate()
        steps["endDate"] = NSDate()
        steps.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                println("saved")
            }
        }
        
        var query = PFQuery(className: "StepRecord")
        
        let stepCount = steps["stepCount"] as! Int
        let userName = steps[""] as! PFUser
        let startDate = steps["startDate"] as! NSDate
        let endDate = steps["endDate"] as! NSDate
        
        let objectId = steps.objectId
        let updatedAt = steps.updatedAt
        let createdAt = steps.createdAt
        
        
        
        println("\(userName) has taken a total of \(stepCount) from \(startDate)")
        
    }
    
    
    
    
    
    
    
}
extension ChallengesViewController: UITableViewDataSource {
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChallengeCell", forIndexPath: indexPath) as! UITableViewCell
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
}
