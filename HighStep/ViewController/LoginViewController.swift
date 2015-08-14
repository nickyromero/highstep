//
//  LoginViewController.swift
//  HighStep
//
//  Created by Maverick on 7/18/15.
//  Copyright (c) 2015 Maverick. All rights reserved.
//

import UIKit
import Parse


class LoginViewController: UIViewController, UITextFieldDelegate{

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
        self.usernameField.becomeFirstResponder()

    }
    
    
     func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameField{
            passwordField.becomeFirstResponder()
        } else{
            passwordField.resignFirstResponder()
        }
        return true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: Actions
    
    @IBAction func loginButton(sender: UIButton) {
        
        var username = self.usernameField.text.lowercaseString
        var password = self.passwordField.text
        

        if (count(username) < 2 || count(password) < 1){
            
            var alert = UIAlertView(title: "Invalid", message: "Username must be greater than 2 & Password must be greater than 1 characters", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
        } else{
            self.actInd.startAnimating()
            
            PFUser.logInWithUsernameInBackground(username, password: password, block: {(user, error) -> Void in
             self.actInd.stopAnimating()
                
                if((user) != nil ){
                    
                    var alert = UIAlertView(title: "Success", message: "Logged In", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    self.navigationController?.popViewControllerAnimated(true)
                    
                    
                } else{
                    var alert = UIAlertView(title: "Error", message: "Hmm... that did not work, try again!", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    
                    self.usernameField.text = ""
                    self.passwordField.text = ""
                    
                    
                    
                }
            })
        }
    }
    
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
            self.view.endEditing(true)
    }
    
    
}
