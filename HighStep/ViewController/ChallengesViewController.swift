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
    
    var arrayOfChallenges: [PFObject] = []
    var completedFinalChallenges: [PFObject] = []
    var expiredChallenges: [PFObject] = []
    var timeLeftChallenges: [PFObject] = []
    var inProgressChallenges = 0
    
    func refresh(sender: UIRefreshControl){
        // Updating your data here...
        self.updateCurrentUserStepCount()
        self.queryChallenges()
        
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
   
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        queryChallenges()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        self.tableView.reloadData()
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
                
                self.checkForIncompleteChallenges(challenges)
                
//                self.challenges = challenges
//                self.tableView.reloadData()
//                println("total challenges for currentUser: \(self.challenges.count)")
//                self.checkForIncompleteChallenges()
//                self.updateCurrentUserStepCount()
                
            }
        }
        
    }
    
    func checkForIncompleteChallenges(someChallenges: Array<PFObject>) {
      
        var challenges = someChallenges
        expiredChallenges.removeAll(keepCapacity: false)
        completedFinalChallenges.removeAll(keepCapacity: false)
        timeLeftChallenges.removeAll(keepCapacity: false)
        
        for challenge in challenges {
           
            // create a method to pass the single challenge into a check for completion
            var endDate = challenge["endDate"] as! NSDate
            var updatedAt = challenge.updatedAt!
            var fromUserStepCount = challenge["stepCountFromUser"] as? Int
            var toUserStepCount = challenge["stepCountToUser"] as? Int
           
            let endDateIsGreater: Bool = endDate > NSDate()
            let challengeIsFinal: Bool = (endDate < NSDate()) && (updatedAt > endDate) && (toUserStepCount != nil)  && (fromUserStepCount != nil)
            
            if (endDateIsGreater) {
                
                // this challenge is in progress, and needs to update the current users current step count
                timeLeftChallenges.append(challenge)
                
            }  else if (challengeIsFinal) {
                
                // final - no more updating for these challenges
                //completedFinalChallenges.append(challenge)
                arrayOfChallenges.append(challenge)
            
            } else {
                
                // challenge expired, now just needs to update final step count for current user
                expiredChallenges.append(challenge)
                
            }
        }
        
        
        println("time left challenges: \(timeLeftChallenges.count)")
        println("completed: \(expiredChallenges.count)")
        println("completed FINAL: \(arrayOfChallenges.count)")
        
    }
    

    
    
    func updateCurrentUserStepCount() {
        
        for challenge in timeLeftChallenges {
            HealthKitManager.updateChallenge(challenge)
        }
        
        for challenge in expiredChallenges {
            HealthKitManager.updateChallenge(challenge)
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
    
    @IBAction func settingsButtonTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("toSettings", sender: sender)
        
        
    }
    @IBAction func addButtonTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("challengeAUser", sender: sender)
        
    }
}
extension ChallengesViewController: UITableViewDataSource {
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChallengeCell", forIndexPath: indexPath) as! ChallengeTableViewCell
        
        var curRow = indexPath.row
        
        if indexPath.section == 1 {
            curRow += inProgressChallenges
        }
        
        
        let aChallenge = self.arrayOfChallenges[curRow] as PFObject
        
        let fromUser = aChallenge["fromUser"] as? PFUser
        let toUser = aChallenge["toUser"] as? PFUser
  
        let stepCountFromUser = aChallenge["stepCountFromUser"] as? Int
        let stepCountToUser = aChallenge["stepCountToUser"] as? Int
        
        
    
        if  (PFUser.currentUser()?.username == fromUser?.username) {
        
            cell.currentUser.text = fromUser?.username
            cell.challengeUser.text = toUser?.username
            cell.stepCountCurrentUser.text = stepCountFromUser?.description
            cell.stepCountChallengeUser.text = stepCountToUser?.description
            
        } else  {
            
            cell.currentUser.text = toUser?.username
            cell.challengeUser.text = fromUser?.username
            cell.stepCountCurrentUser.text = stepCountToUser?.description
            cell.stepCountChallengeUser.text = stepCountFromUser?.description
    
        }
        
        
        let endDate = aChallenge["endDate"] as? NSDate
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        cell.endDate.text =  formatter.stringFromDate(endDate!)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "In Progress" // timeleft
        } else if section == 1{
                return  "Waiting on Opponent!" //completed challenges
        }
            else {
            return "History" //completed final challenges
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return timeLeftChallenges.count
        } else if section == 1{
            return expiredChallenges.count
        } else{
            return completedFinalChallenges.count
        }
        
        
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
}


public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }