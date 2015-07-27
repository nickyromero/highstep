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
    
    var challenges: [PFObject] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var query = PFQuery(className: "Challenge")
        query.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        query.whereKey("toUser", notEqualTo: PFUser.currentUser()!)
        query.includeKey("fromUser")
        query.includeKey("toUser")
        
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error: NSError?) -> Void in
            if let challenges = objects as? [PFObject]{
                self.challenges = challenges
                self.tableView.reloadData()
                println("\(self.challenges.count)")
                for challenge in challenges{
                    println("\(challenge)")
                }
            }
        }
    }
    
    
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if (segue.identifier == "ChallengeCell"){
        
        var challengeDetailScene = segue.destinationViewController as? ChallengeTableViewCell
        
        }
    }
    
    
    
    //        let challengeArray: Void = query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
    //            if let challenges = objects as? [PFObject]{
    //                self.challenges = challenges
    //                self.tableView.reloadData()
    //
    //
    //            }
    ////        }
    //         println("\(challengeArray)")
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //    MARK: ACTIONS
    
    @IBAction func addButtonTapped(sender: UIBarButtonItem) {
        
    }
}
extension ChallengesViewController: UITableViewDataSource {
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChallengeCell", forIndexPath: indexPath) as! ChallengeTableViewCell
        
        let aChallenge = self.challenges[indexPath.row] as PFObject
        
        let fromUser = aChallenge["fromUser"] as? PFUser
        let toUser = aChallenge["toUser"] as? PFUser
        
        cell.fromUser.text = fromUser?.username
        cell.toUser.text = toUser?.username
        
        let stepCountFromUser = aChallenge["stepCountFromUser"] as? Int
        let stepCountToUser = aChallenge["stepCountToUser"] as? Int
        
        cell.stepCountFromUser.text = stepCountFromUser?.description
        cell.stepCountToUser.text = stepCountToUser?.description
        
        let startDate = aChallenge["startDate"] as? NSDate
        let endDate = aChallenge["endDate"] as? NSDate
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
     
        cell.startDate.text =  formatter.stringFromDate(startDate!)
        cell.endDate.text =  formatter.stringFromDate(endDate!)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return challenges.count ?? 0
    }
}


//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.dataSource = self
//
//        let endDate = NSDate()
//        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitHour, value: -2, toDate: endDate, options: nil)
//
//        HealthKitManager.queryStepsFromDate(startDate!, toDate: endDate) {
//            (steps: Double) in
//
//            println("past 2 hours day steps:")
//
//            println(steps)
//        }
//
//        HealthKitManager.queryStepsFromPastDay {
//            (steps: Double) in
//
//            println("past day steps:")
//            println(steps)
//
//        }

//
//  FUNC ADD BUTTON PRESSED>>> save to POST to stepRecord
//        let endDate = NSDate()
//        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: -1, toDate: endDate, options: nil)
//
//        HealthKitManager.queryStepsFromDate(startDate!, toDate: endDate) {
//            (steps: Double) in
//
//            println("past 2 hours day steps for:")
//            println(steps)
//
//        var stepRecord = PFObject(className:"StepRecord")
//        stepRecord["stepCount"] = steps
//        stepRecord["userName"] = PFUser.currentUser()
//        stepRecord["startDate"] = startDate!
//        stepRecord["endDate"] = endDate
//        stepRecord.saveInBackgroundWithBlock { (success, error) -> Void in
//            if success {
//                println("saved")
//            }
//            else{
//                println("\(error)")
//                }
//            }
//        }

