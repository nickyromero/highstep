//
//  UsersTableViewController.swift
//  HighStep
//
//  Created by Maverick on 7/23/15.
//  Copyright (c) 2015 Maverick. All rights reserved.
//

import UIKit
import Parse

class UsersTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var users : [PFUser] = []
    var searchActive : Bool = false
    @IBOutlet weak var userSearchBar: UISearchBar!
    var filtered:[PFUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        userSearchBar.delegate = self
        reloadChallengedUsers()
        
    }
    func reloadChallengedUsers() {
        users = [PFUser]()
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
                for challenge in challenges {
                    if let fromUser = challenge.objectForKey("fromUser") as? PFUser, let toUser = challenge.objectForKey("toUser") as? PFUser {
                        //
                        var user : PFUser;
                        if(fromUser.username!==PFUser.currentUser()!.username!) {
                            user = toUser
                        } else {
                            user = fromUser
                        }
                        var contains = false
                        for existingUser in self.users {
                            if(existingUser.username == user.username) {
                                contains = true
                                break
                            }
                        }
                        if !contains {
                            self.users.append(user)
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filtered.count ?? 0
        } else {
            return users.count ?? 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UsersTableViewCell
        
        var aUser : PFUser
        if(searchActive){
            aUser = filtered[indexPath.row]
        } else {
            aUser = self.users[indexPath.row]
        }

        cell.userBeingChallenged = aUser
        cell.userNames.text = aUser.username
        
        return cell
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }

   

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {

        if(count(searchText) == 0){
            searchActive = false;
            reloadChallengedUsers()
        } else {
            searchActive = true;
            let query = PFQuery(className: "_User")
            query.whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
            query.whereKey("username", matchesRegex: searchText, modifiers: "i")
            query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error: NSError?) -> Void in
                if let users = objects as? [PFUser] {
                    self.filtered = users
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        return nil
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      
        
        if (searchActive){
            return "Search Results.. Tap Challenge!"
        } else{
        
        return "\(users.count) Recent Challengers"
        }
}
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.whiteColor()
        
        header.textLabel.textColor = UIColor(red: 192/255, green: 31/255, blue: 41/255, alpha: 1)
        header.contentView.backgroundColor =  UIColor.whiteColor()
        header.textLabel.font = UIFont(name: "SFUIDisplay-Thin", size: 15)!
        
        

        
    }


}

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

