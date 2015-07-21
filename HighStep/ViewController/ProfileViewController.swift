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

    //MARK: HEALTHKIT AUTHORIZATION
    
    let healthKitManager: HealthKitManager = HealthKitManager()
    
    
     //MARK: ACTIONS
    
    @IBAction func authorizeHealthData() {
        healthKitManager.setupHealthStoreIfPossible { (success:Bool, error: NSError!) -> Void in
            println("Completed")
        }
    }
    
    @IBAction func loginButton(sender: UIButton) {
        self.performSegueWithIdentifier("login", sender: self)
    }
    
    @IBAction func logoutButton(sender: UIButton) {
        PFUser.logOut()
    }
        
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        }
 
    //MARK: PARSE
    
    
    var logInViewController: PFLogInViewController! = PFLogInViewController()
    var signUpViewController: PFSignUpViewController! = PFSignUpViewController()
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (PFUser.currentUser() == nil){
            self.logInViewController.fields = PFLogInFields.UsernameAndPassword | PFLogInFields.LogInButton | PFLogInFields.SignUpButton | PFLogInFields.PasswordForgotten | PFLogInFields.DismissButton
            
            var logInLogoTitle = UILabel()
            logInLogoTitle.text = "High Step"
            
            self.logInViewController.logInView?.logo = logInLogoTitle
            self.logInViewController.delegate = self
            
            var signUpLogoTitle = UILabel()
            signUpLogoTitle.text = "High Step"
            
            self.signUpViewController.signUpView?.logo = signUpLogoTitle
            self.signUpViewController.delegate = self
            self.logInViewController.signUpController = self.signUpViewController
            
        }
    }

    // MARK: Parse Login
    
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        
        if (!username.isEmpty || !password.isEmpty){
            return true
        } else {
            return false
        }
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        println("Failed to login")
    }
    
    
    // MARK: Parse SignUp
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        println("Failed to sign up....")
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
        println("User dismissed sign up.")
    }
}
