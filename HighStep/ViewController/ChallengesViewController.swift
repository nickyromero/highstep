//
//  ChallengesViewController.swift
//  HighStep
//
//  Created by Maverick on 7/17/15.
//  Copyright (c) 2015 Maverick. All rights reserved.
//

import UIKit

class ChallengesViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   
}
//
//extension ChallengesViewController: UITableViewDataSource {
//    
//    
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("ChallengeCell", forIndexPath: indexPath) as! ChallengesViewController
//        
//        
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 5
//    }
//    }
//}
