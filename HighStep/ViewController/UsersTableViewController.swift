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
    
    var users: [PFUser]?
    var searchActive : Bool = false
    @IBOutlet weak var userSearchBar: UISearchBar!
    
//    var filtered:[String] = []
//
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        tableView.delegate = self
//        tableView.dataSource = self
////        searchBar.delegate = self
        

        
        var query = PFQuery(className: "_User")
        query.whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
        query.findObjectsInBackgroundWithBlock {(objects: [AnyObject]?, error: NSError?) -> Void in
            if let users = objects as? [PFUser] {
                self.users = users
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
        return users?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UsersTableViewCell
        
        
        
//        
//        if(searchActive){
//            cell.textLabel?.text = filtered[indexPath.row]
//        } else {
//            cell.textLabel?.text = data[indexPath.row];
//        }
        
        
        let aUser = self.users![indexPath.row] as PFUser
        
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

   
//
//    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        
//        filtered = data.filter({ (text) -> Bool in
//            let tmp: NSString = text
//            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
//            return range.location != NSNotFound
//        })
//        if(filtered.count == 0){
//            searchActive = false;
//        } else {
//            searchActive = true;
//        }
//        self.tableView.reloadData()
//    }




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

