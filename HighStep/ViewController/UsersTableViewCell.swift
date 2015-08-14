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
        
            if let curUser = PFUser.currentUser(), userBeingChallenged = self.userBeingChallenged {
                var challenge = PFObject(className:"Challenge")
                challenge["fromUser"] = curUser
                challenge["stepCountFromUser"] = 0
                challenge["toUser"] = userBeingChallenged
                challenge["stepCountToUser"] = 0
                challenge["toUserHasAccepted"] = false
                
                challenge.saveInBackgroundWithBlock { (success, error) -> Void in
                    if success {
                     sender.userInteractionEnabled = false
                        
                        
                        
                        println("saved")
                    self.backgroundColor = UIColor(red:  192/255, green: 31/255, blue: 41/255, alpha: 1)
                    self.textLabel?.textColor = UIColor.whiteColor()
                    self.userNames.textColor = UIColor.whiteColor()
                    var userNamed: String = self.userBeingChallenged!.objectForKey("username") as! String
                    self.textLabel?.text = "pending challenge against \(userNamed)!"
                    self.textLabel?.textAlignment = NSTextAlignment.Center
                    
                     
                        
                        var userQuery: PFQuery = PFUser.query()!
                        userQuery.whereKey("username", equalTo: userNamed)
                        var query: PFQuery = PFInstallation.query()!
                        query.whereKey("user", matchesQuery: userQuery)
                        
                        var push: PFPush = PFPush()
                        push.setQuery(query)
                    
                        push.setMessage("\(PFUser.currentUser()!.username!) challenged you!")
                        push.sendPushInBackgroundWithBlock({
                            (isSuccessful: Bool, error: NSError?) -> Void in
                            println(isSuccessful)
                        })
                        
                        
                        
                        
                        
                      
                    } else {
                        println("\(error)")
                    }
                }
            }
        }
        
    }

