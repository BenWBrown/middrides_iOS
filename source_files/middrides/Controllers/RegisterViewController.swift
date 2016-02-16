//
//  RegisterViewController.swift
//  middrides
//
//  Created by Ben Brown on 10/3/15.
//  Copyright © 2015 Ben Brown. All rights reserved.
//

import UIKit
import Parse

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var ConfirmPassword: UITextField!
    @IBOutlet weak var letsRideButton: UIButton!
    
    func setInfo(username: String, password: String){
        self.Username.text = username;
        self.Password.text = password;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Username.delegate = self
        Password.delegate = self
        ConfirmPassword.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        registerButtonPressed(letsRideButton)
        
        return true
    }
    
    @IBAction func registerButtonPressed(sender: UIButton) {
        
        if validRegisterDetails((self.Username?.text)!, password: (self.Password?.text)!, confirm: (self.ConfirmPassword.text)!) {
            //check that username and password are valid
            
            //create user in Parse
            var user = PFUser();
            user.username = self.Username.text!;
            user.password = self.Password.text!;
            user.email = self.Username.text!;
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                if let error = error {
                    if let errorString = error.userInfo["error"] as? NSString {
                        self.displayPopUpMessage("Error", message: errorString as String)
                        print(errorString)
                    }
                }
            }
            
            
            self.performSegueWithIdentifier("registerViewToLoginView", sender: self)
        }
        else {
            //transition to error message
        }
    }
    
    //verify register credentials
    func validRegisterDetails(username: String, password: String, confirm: String) -> Bool {
        
        if ((username.hasSuffix("@middlebury.edu")) == false){
            //make sure we have a valid email
            self.displayPopUpMessage("Error", message: "Please enter a valid Middlebury email address")
            return false;
        }
        
        if (password.characters.count < 6){
            //make sure there are 6 characters in a password
            self.displayPopUpMessage("Error", message: "Password must be at least 6 characters")
            return false;
        }
        
        if password != confirm {
            self.displayPopUpMessage("Error", message: "Passwords do not match")
            return false
        }
        
        return true;
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
