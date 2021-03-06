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
    
    @IBOutlet weak var addNewChallengeButton: UIBarButtonItem!
    
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
            NSFontAttributeName: UIFont(name: "SFUIDisplay-Bold", size: 33)!]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        self.actInd.center = self.view.center
        self.actInd.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.Gray
        
        view.addSubview(self.actInd)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser() == nil{
            addNewChallengeButton.enabled = false
            
            
            performSegueWithIdentifier("toSettings", sender: self)
            
            
            return
        }
        addNewChallengeButton.enabled = true
        queryChallenges()
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
//                var updatedAt = challenge.updatedAt!
                var fromUserUpdatedAt = challenge["fromUserUpdate"] as? NSDate
                var toUserUpdatedAt = challenge["toUserUpdate"] as? NSDate

                var fromUserStepCount = challenge["stepCountFromUser"] as? Int
                var toUserStepCount = challenge["stepCountToUser"] as? Int
                let challengeIsFinal: Bool = (endDate < NSDate()) && (toUserUpdatedAt > endDate) && (fromUserUpdatedAt > endDate)
                
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
        cell.selectionStyle = UITableViewCellSelectionStyle.Blue
        

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
        
        let toUserUpdate = aChallenge["toUserUpdate"] as? NSDate
        let fromUserUpdate = aChallenge["fromUserUpdate"] as? NSDate
        
        let stepCountFromUser = aChallenge["stepCountFromUser"] as? Int
        let stepCountToUser = aChallenge["stepCountToUser"] as? Int
        
        let endDate = aChallenge["endDate"] as? NSDate
        let formatter = NSDateFormatter()
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        cell.endDate.text =  formatter.stringFromDate(endDate!)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        
        if  (PFUser.currentUser()?.username == fromUser?.username) {
            
            cell.currentUser.text = fromUser?.username
            cell.challengeUser.text = toUser?.username
            let stepFromString = stepCountFromUser!.description
            let stepToString = stepCountToUser!.description
            
            cell.stepCountCurrentUser.text = "\(stepFromString)"
            cell.stepCountChallengeUser.text = "\(stepToString)"
            
            if let stepCountFromUser = stepCountFromUser, let stepCountToUser = stepCountToUser {
                let totalSteps = (stepCountFromUser + stepCountToUser)
                
                var currentUserProgress = Float(stepCountFromUser) / Float(totalSteps)
                
                cell.progressBar.setProgress(currentUserProgress, animated: true)
                
                if endDate < NSDate() {
                    if toUserUpdate > endDate {
                        if stepCountFromUser > stepCountToUser{
                            cell.currentUser.text = "\(fromUser!.username!) 🏆"
                            
                        } else if stepCountFromUser < stepCountToUser {
                            cell.challengeUser.text = "🏆 \(toUser!.username!)"
                        }
                    } else {
                        cell.stepCountChallengeUser.text = "????"
                    }
                }
            }
        } else  {
            
            cell.currentUser.text = toUser?.username
            cell.challengeUser.text = fromUser?.username
            
            let stepFromString = stepCountFromUser!.description
            let stepToString = stepCountToUser!.description
            
            cell.stepCountCurrentUser.text = "\(stepToString)"
            cell.stepCountChallengeUser.text = "\(stepFromString)"
            
            
            if endDate < NSDate() {
                if fromUserUpdate > endDate {
                    if stepCountFromUser > stepCountToUser{
                        cell.challengeUser.text = "🏆 \(fromUser!.username!)"
                        
                    } else if stepCountFromUser < stepCountToUser {
                        cell.currentUser.text = "\(toUser!.username!) 🏆"
                    }
                } else {
                    cell.stepCountChallengeUser.text = "????"
                }
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
        
        header.textLabel.textColor = UIColor.whiteColor()
        header.contentView.backgroundColor = UIColor(red: 192/255, green: 31/255, blue: 41/255, alpha: 1)
        header.textLabel.font = UIFont(name: "SFUIDisplay-Thin", size: 15)!
        
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let startDate = NSDate()
        let endDate = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: 1, toDate: startDate, options: nil)
        var aChallenge : PFObject!
        //        let fromUser: PFUser = aChallenge.objectForKey("fromUser") as! PFUser
        
        
        if indexPath.section == 0{
            aChallenge = self.toAcceptChallenges[indexPath.row]
            
            aChallenge["startDate"] = startDate
            aChallenge["endDate"] = endDate!
            aChallenge["toUserHasAccepted"] = true
            aChallenge["needFinalUpdate"] = true
            
   
            aChallenge.saveInBackgroundWithBlock { (success, error) -> Void in
                if success {
                    println("saved")
                    self.toAcceptChallenges.removeAtIndex(indexPath.row)
                    self.tableView.reloadData()
                    
                    
                    let fromUser = aChallenge.objectForKey("fromUser") as! PFUser
                    
                    if let toUser = aChallenge.objectForKey("toUser")  as? PFUser {
                        var query: PFQuery = PFInstallation.query()!
                        query.whereKey("user", equalTo: fromUser)
                        
                        var push: PFPush = PFPush()
                        push.setQuery(query)
                        
                        push.setMessage("\(toUser.username!) accepted your challenge!")
                        
                        
                        push.sendPushInBackgroundWithBlock({
                            (isSuccessful: Bool, error: NSError?) -> Void in
                            println(isSuccessful)
                        })
                    }
                    
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
    
    
    
//        override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//            return true
//        }
//    
//    
//        override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//            if (editingStyle == UITableViewCellEditingStyle.Delete) {
//                // handle delete (by removing the data from your array and updating the tableview)
//                var aChallenge : PFObject!
//    
//    
//    
//            }
//        }
    
}   





public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }