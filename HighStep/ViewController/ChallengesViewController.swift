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
    var uncompletedChallenges: [PFObject] = []

    var inProgressChallenges = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        queryChallenges()
    }
    

    func queryChallenges() {
        
        var fromQuery = PFQuery(className: "Challenge")
        fromQuery.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        let toQuery = PFQuery(className: "Challenge")
        toQuery.whereKey("toUser", equalTo: PFUser.currentUser()!)
        let query = PFQuery.orQueryWithSubqueries([fromQuery, toQuery])
        query.includeKey("fromUser")
        query.includeKey("toUser")
        query.orderByDescending("endDate")
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error: NSError?) -> Void in
            if let challenges = objects as? [PFObject] {
                self.challenges = challenges
                self.tableView.reloadData()
                println("total challenges for currentUser: \(self.challenges.count)")
                //self.checkForIncompleteChallenges()
                self.queryForIncompleteChallenges()
            }
        }

    }
    
    
    func checkForIncompleteChallenges() {
        for challenge in self.challenges {
            var fromUserCount = challenge["stepCountFromUser"] as! NSNumber?
            var toUserCount = challenge["stepCountToUser"] as! NSNumber?
            var isIncomplete: Bool = (fromUserCount == nil) && (toUserCount == nil)
            if (isIncomplete) {
                println(challenge)
            }
        }
    }
    
    func queryForIncompleteChallenges() {
        let aQuery = PFQuery(className: "Challenge")
        aQuery.whereKey("stepCountFromUser", equalTo: NSNull())
        
        let bQuery = PFQuery(className: "Challenge")
        bQuery.whereKey("stepCountToUser", equalTo: NSNull())
        
        let cQuery = PFQuery.orQueryWithSubqueries([aQuery, bQuery])
        cQuery.includeKey("fromUser")
        cQuery.includeKey("toUser")

//        cQuery.whereKey("endDate", greaterThan: NSDate())
        cQuery.findObjectsInBackgroundWithBlock { (challenges, anError) -> Void in
            if (anError != nil) {
                return
            }
            
            println("Incomplete challenges: \(challenges!.count)")
        }
    }
    
// MARK: ********************************************************************
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if (segue.identifier == "ChallengeCell"){
            
            var challengeDetail = segue.destinationViewController as? ChallengeDetailViewController
            
        }
    }
    
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
        
        var curRow = indexPath.row
        
        if indexPath.section == 1 {
            curRow += inProgressChallenges
        }
        
        
        let aChallenge = self.challenges[curRow] as PFObject
        
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
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "In Progress"
        } else {
            return "Past"
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if challenges.count > 0 {
            
            let curDate = NSDate()
            var index = 0
            
            if var curEndDate: NSDate = challenges[index]["endDate"] as? NSDate {
                while index < challenges.count - 1 && curEndDate > curDate {
                    index++
                    curEndDate = challenges[index]["endDate"] as! NSDate
                }
            }
            
            inProgressChallenges = index
            
            if section == 0 {
                return index
            } else {
                
                return challenges.count - index
            }
        }
        return 0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
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



public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }