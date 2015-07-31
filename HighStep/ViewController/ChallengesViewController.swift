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
    var toUpdateChallenges: [PFObject] = []
    var inProgressChallenges = 0
    
    func refresh(sender: UIRefreshControl){
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
            }
        }
        
    }
    
    func checkForIncompleteChallenges(someChallenges: Array<PFObject>) {
        
        var challenges = someChallenges
        toUpdateChallenges.removeAll(keepCapacity: true)
        //        if arrayOfChallenges.count > 0 {
        arrayOfChallenges.removeAll(keepCapacity: true)
        //        }
        
        // could put on diff thread
        for challenge in challenges {
            
            // create a method to pass the single challenge into a check for completion
            var endDate = challenge["endDate"] as! NSDate
            var updatedAt = challenge.updatedAt!
            var fromUserStepCount = challenge["stepCountFromUser"] as? Int
            var toUserStepCount = challenge["stepCountToUser"] as? Int
            let challengeIsFinal: Bool = (endDate < NSDate()) && (updatedAt > endDate) && (toUserStepCount != nil)  && (fromUserStepCount != nil)
            
            if (challengeIsFinal) {
                // final - no more updating for these challenges
                arrayOfChallenges.append(challenge)
            } else {
                // challenge expired, now just needs to update final step count for current user
                toUpdateChallenges.append(challenge)
            }
        }
        updateCurrentUserStepCount()
        println("time left challenges: \(toUpdateChallenges.count)")
        println("completed FINAL: \(arrayOfChallenges.count)")
        
    }
    
    func updateCurrentUserStepCount() {
        HealthKitManager.updateChallenge(toUpdateChallenges, withClosure: { (isDone, challenges) -> Void in
            if isDone {
                println("fdsfdsgfdgfdgfdgfd")
                println(challenges[0]["stepCountFromUser"])
                self.toUpdateChallenges.removeAll(keepCapacity: true)
                self.toUpdateChallenges = challenges
                self.updateChallenges(self.toUpdateChallenges)
            }
        })
    }
    
    func updateChallenges(withChallenges: Array<PFObject>) {
        PFObject.saveAllInBackground(withChallenges, block: { (didUpdate, error) -> Void in
            if error != nil {
                return
            }
            self.tableView.reloadData()
            
        })
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
//        
//        if indexPath.section == 0 {
//            print(toUpdateChallenges[indexPath.row])
//        } else {
//            print(arrayOfChallenges[indexPath.row])
//        }
        
        var aChallenge : PFObject!
        
        if indexPath.section == 0 {
            aChallenge = self.toUpdateChallenges[indexPath.row]
        } else {
            aChallenge = self.arrayOfChallenges[indexPath.row]
        }
        
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
        //
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "In Progress" // in progress
        }
        else {
            return "History" // final challenges
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return toUpdateChallenges.count
        } else {
            return arrayOfChallenges.count
        }
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
}


public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }