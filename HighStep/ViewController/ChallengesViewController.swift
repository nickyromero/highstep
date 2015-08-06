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
    var pendingChallenges: [PFObject] = []
    var toAcceptChallenges: [PFObject] = []
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView

    
    func refresh(sender: UIRefreshControl){
        self.queryChallenges()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        
        var attributes = [NSForegroundColorAttributeName: UIColor(red:  192/255, green: 31/255, blue: 41/255, alpha: 1),
            NSFontAttributeName: UIFont(name: "SFUIDisplay-Thin", size: 33)!]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        self.actInd.center = self.view.center
        self.actInd.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.Gray
        
        view.addSubview(self.actInd)

    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser() == nil{
            performSegueWithIdentifier("toSettings", sender: self)
            return
        }
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
                self.checkForIncompleteChallenges(challenges)
            }
        }
    }
    
    func checkForIncompleteChallenges(someChallenges: Array<PFObject>) {
        
        var challenges = someChallenges
        
        toUpdateChallenges.removeAll(keepCapacity: true)
        arrayOfChallenges.removeAll(keepCapacity: true)
        pendingChallenges.removeAll(keepCapacity: true)
        toAcceptChallenges.removeAll(keepCapacity: true)
        
        // could put on diff thread
        for challenge in challenges {
            
            var toUser = challenge["toUser"] as! PFUser
            var fromUser = challenge["fromUser"] as! PFUser
            
            var isAPendingChallenge = challenge["toUserHasAccepted"] as? Bool
            
            if (isAPendingChallenge == false){
                if PFUser.currentUser()?.username! == toUser.username! {
                    toAcceptChallenges.append(challenge)
                } else{
                    pendingChallenges.append(challenge)
                }
                
            } else{
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
        }
        
        updateCurrentUserStepCount()
        println("time left challenges: \(toUpdateChallenges.count)")
        println("completed FINAL: \(arrayOfChallenges.count)")
        println("pending: \(pendingChallenges.count)")
        println("to be Accepted: \(toAcceptChallenges.count)")
        
        self.tableView.reloadData()
    }
    
    
    
    func updateCurrentUserStepCount() {
        HealthKitManager.updateChallenge(toUpdateChallenges, withClosure: { (isDone, challenges) -> Void in
            if isDone {
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
    
    func pendingChallengeCellForChallenge(aChallenge: PFObject, indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("PendingChallengeCell", forIndexPath: indexPath) as! PendingChallengeTableViewCell
        
        let fromUser = aChallenge["fromUser"] as? PFUser
        let toUser = aChallenge["toUser"] as? PFUser
        
        if  (PFUser.currentUser()?.username == fromUser?.username) {
            cell.challengeUser.text = "waiting for \(toUser!.username!) to accept!"
            
        } else{
            cell.challengeUser.text = "accept challenge from \(fromUser!.username!)"
        }
        cell.challengeUser.textColor = UIColor(red:  192/255, green: 31/255, blue: 41/255, alpha: 1)
        
        return cell
    }
    
    func challengeCellForChallenge(aChallenge: PFObject, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChallengeCell", forIndexPath: indexPath) as! ChallengeTableViewCell
        
        let fromUser = aChallenge["fromUser"] as? PFUser
        let toUser = aChallenge["toUser"] as? PFUser
        
        let stepCountFromUser = aChallenge["stepCountFromUser"] as? Int
        let stepCountToUser = aChallenge["stepCountToUser"] as? Int
        
        let endDate = aChallenge["endDate"] as? NSDate
        let formatter = NSDateFormatter()
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        cell.endDate.text =  formatter.stringFromDate(endDate!)
        
        if  (PFUser.currentUser()?.username == fromUser?.username) {
            
            cell.currentUser.text = fromUser?.username
            cell.challengeUser.text = toUser?.username
            let stepFromString = stepCountFromUser!.description
            let stepToString = stepCountToUser!.description
            
            cell.stepCountCurrentUser.text = "\(stepFromString) steps"
            cell.stepCountChallengeUser.text = "\(stepToString) steps"
            
            if let stepCountFromUser = stepCountFromUser, let stepCountToUser = stepCountToUser {
                let totalSteps = (stepCountFromUser + stepCountToUser)
                
                var currentUserProgress = Float(stepCountFromUser) / Float(totalSteps)
                
                cell.progressBar.setProgress(currentUserProgress, animated: true)
                
                if endDate < NSDate() && stepCountFromUser > stepCountToUser{
                    cell.currentUser.text = "\(fromUser!.username!) 🏆"
                    
                } else if (endDate < NSDate() && stepCountFromUser < stepCountToUser){
                    cell.challengeUser.text = "🏆 \(toUser!.username!)"
                }
            }
            
        } else  {
            
            cell.currentUser.text = toUser?.username
            cell.challengeUser.text = fromUser?.username
            
            let stepFromString = stepCountFromUser!.description
            let stepToString = stepCountToUser!.description
            
            cell.stepCountCurrentUser.text = "\(stepToString) steps"
            cell.stepCountChallengeUser.text = "\(stepFromString) steps"
            
            
            if endDate < NSDate() && stepCountFromUser > stepCountToUser{
                cell.challengeUser.text = "🏆 \(fromUser!.username!)"
                
                
            } else if (endDate < NSDate() && stepCountFromUser < stepCountToUser){
                cell.currentUser.text = "\(toUser!.username!) 🏆"
                
            }
            
            if let stepCountFromUser = stepCountFromUser, let stepCountToUser = stepCountToUser {
                let totalSteps = (stepCountFromUser + stepCountToUser)
                var currentUserProgress = Float(stepCountToUser) / Float(totalSteps)
                
                cell.progressBar.setProgress(currentUserProgress, animated: true)
            }
        }
        
        if endDate < NSDate(){
            cell.endDate.text = "🏁"
        }
        
        cell.progressBar.layer.cornerRadius = 22
        cell.progressBar.layer.masksToBounds = true
        cell.progressBar.clipsToBounds = true
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.whiteColor()
        
        header.textLabel.textColor = UIColor(red: 192/255, green: 31/255, blue: 41/255, alpha: 1)
        header.contentView.backgroundColor =  UIColor.whiteColor()
        header.textLabel.font = UIFont(name: "SFUIDisplay-Thin", size: 15)!
        
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let startDate = NSDate()
        let endDate = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: 1, toDate: startDate, options: nil)
        var aChallenge : PFObject!
        
        if indexPath.section == 0{
            aChallenge = self.toAcceptChallenges[indexPath.row]
            
            aChallenge["startDate"] = startDate
            aChallenge["endDate"] = endDate!
            aChallenge["toUserHasAccepted"] = true
            
            
            
            aChallenge.saveInBackgroundWithBlock { (success, error) -> Void in
                if success {
                    println("saved")
                    self.toAcceptChallenges.removeAtIndex(indexPath.row)
                    self.tableView.reloadData()
                } else {
                    println("\(error)")
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        if indexPath.section != 0{
            return nil
        }
        return indexPath
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var aChallenge : PFObject!
        var cell: UITableViewCell!
        
        switch indexPath.section
        {
        case 0:
            aChallenge = self.toAcceptChallenges[indexPath.row]
            cell = pendingChallengeCellForChallenge(aChallenge, indexPath:indexPath)
            self.tableView.rowHeight = 70.0
        case 1:
            aChallenge = self.toUpdateChallenges.reverse()[indexPath.row]
            cell = challengeCellForChallenge(aChallenge, indexPath:indexPath)
            self.tableView.rowHeight = 140.0
        case 2:
            aChallenge = self.arrayOfChallenges[indexPath.row]
            cell = challengeCellForChallenge(aChallenge, indexPath:indexPath)
            self.tableView.rowHeight = 140.0
        case 3:
            aChallenge = self.pendingChallenges[indexPath.row]
            cell = pendingChallengeCellForChallenge(aChallenge, indexPath:indexPath)
            self.tableView.rowHeight = 70.0
        default:
            println("Invalid section")
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Tap to Accept Challenges" // current
        } else if section == 1{
            return "\(toUpdateChallenges.count) Current Challenges" //pending
        } else if section == 2{
            return "\(arrayOfChallenges.count) Past Challenges" //final
        } else {
            return "\(pendingChallenges.count) Pending Challenges" // pending challenges
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return toAcceptChallenges.count
        } else if section == 1{
            return toUpdateChallenges.count
        } else if section == 2{
            return arrayOfChallenges.count
        } else {
            return pendingChallenges.count
        }
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }