//
//  ProfileViewController.swift
//  HighStep
//
//  Created by Maverick on 7/17/15.
//  Copyright (c) 2015 Maverick. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ProfileViewController: UIViewController,PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

    var actInd: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
    

    @IBOutlet weak var welcomeUser: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.actInd.center = self.view.center
        self.actInd.hidesWhenStopped = true
        self.actInd.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.Gray
        
        view.addSubview(self.actInd)
        
        if PFUser.currentUser() != nil {
            var user: String = PFUser.currentUser()!.username!
        welcomeUser.text = "Welcome \(user)!"
        } else{
            welcomeUser.text = "Welcome to High Step"
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }

    
    //MARK: HEALTHKIT AUTHORIZATION
    
    let healthKitManager: HealthKitManager = HealthKitManager()
    
     //MARK: ACTIONS
    
    
    
    @IBAction func authorizeHealthData() {
        healthKitManager.setupHealthStoreIfPossible { (success:Bool, error: NSError!) -> Void in
            println("Completed")
        }
    }
    
    @IBAction func loginButton(sender: UIButton) {
        
        if PFUser.currentUser() == nil {
        self.performSegueWithIdentifier("login", sender: self)
        println("loginButton Pressed")
    
  } else{
     var alert = UIAlertView(title: "Invalid", message: "Already logged in!", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
    
    }
    
    @IBAction func logoutButton(sender: UIButton) {
        if PFUser.currentUser() == nil{
            var alert = UIAlertView(title: "Invalid", message: "Nobody is logged in!", delegate: self, cancelButtonTitle: "OK")
            alert.show()

        } else{
            
        println("Log Out Button Pressed")
       var currentUser = PFUser.currentUser()?.username
        println("\(currentUser) is about to be logged out!")
        
        PFUser.logOut()
        
        currentUser = PFUser.currentUser()?.username
        
        if currentUser != nil{
            println("Failed Attempt to LogOut")
        } else{
            println("Successful LogOut")
        }
            welcomeUser.text = "Welcome to High Step!"
        }
        
        
        
    }
    
   
    

    
    
}

//MARK: PARSE NON-CUSTOM


//    var logInViewController: PFLogInViewController! = PFLogInViewController()
//    var signUpViewController: PFSignUpViewController! = PFSignUpViewController()
//

//        if (PFUser.currentUser() == nil){
//            self.logInViewController.fields = PFLogInFields.UsernameAndPassword | PFLogInFields.LogInButton | PFLogInFields.SignUpButton | PFLogInFields.PasswordForgotten | PFLogInFields.DismissButton
//            
//            
//            
//        }
//    // MARK: Parse Login
//    
//    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
//        
//        if (!username.isEmpty || !password.isEmpty){
//            return true
//        } else {
//            return false
//        }
//    }
//    
//    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
//        self.dismissViewControllerAnimated(true, completion: nil)
//        
//    }
//    
//    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
//        println("Failed to login")
//    }
//    
//    
//    // MARK: Parse SignUp
//    
//    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
//        println("Failed to sign up....")
//    }
//    
//    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
//        println("User dismissed sign up.")
//    }
