//
//  SignUpViewController.swift
//  HighStep
//
//  Created by Maverick on 7/20/15.
//  Copyright (c) 2015 Maverick. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.actInd.center = self.view.center
        self.actInd.hidesWhenStopped = true
        self.actInd.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.Gray
        view.addSubview(self.actInd)
        
        self.usernameField.autocapitalizationType = UITextAutocapitalizationType.None
        self.emailField.becomeFirstResponder()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == emailField{
            usernameField.becomeFirstResponder()
        } else if textField == usernameField{
            passwordField.becomeFirstResponder()
        } else{
            passwordField.resignFirstResponder()
        }
        return true
    }
    
    //MARK: ACTIONS
    
    @IBAction func backToLoginButtton(sender: UIButton) {
        
        self.performSegueWithIdentifier("signupToLogin", sender: self)
    }
    
    @IBAction func signUpButton(sender: UIButton) {
        
        var username = self.usernameField.text.lowercaseString
        var password = self.passwordField.text
        var email = self.emailField.text
        
        
        
        
        
        if (count(username) < 2 || count(username) > 12 || count(password) < 1 ){
            
            var alert = UIAlertView(title: "Invalid", message: "Username must be between 3-11 characters & Password must be greater than 1 characters", delegate: self, cancelButtonTitle: "OK")
            
            alert.show()
            self.usernameField.text = ""
            self.passwordField.text = ""
            self.emailField.text = ""
            
            
        } else if (count(email) < 1){
            var alert = UIAlertView(title: "Invalid", message: "Please enter a valid email address", delegate: self, cancelButtonTitle: "OK")
            
            alert.show()
            self.usernameField.text = ""
            self.passwordField.text = ""
            self.emailField.text = ""
        }
        
        else{
            self.actInd.startAnimating()
            
            var newUser = PFUser()
            newUser.username = username
            newUser.password = password
            newUser.email = email
            
            newUser.signUpInBackgroundWithBlock({(succeed, error) -> Void in
                
                self.actInd.stopAnimating()
                
                if ((error) != nil){
                    var alert = UIAlertView(title: "Error", message: "Hmm... that did not work, try again!", delegate: self, cancelButtonTitle: "OK")
                    println("show error alert")
                    
                    alert.show()
                    self.usernameField.text = ""
                    self.passwordField.text = ""
                    self.emailField.text = ""
                    
                } else{
                    var alert = UIAlertView(title: "Success", message: "Signed Up!", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    self.navigationController?.popViewControllerAnimated(true)
                    

                }
            })
        
        
        }
        
    }
    
    


    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
}