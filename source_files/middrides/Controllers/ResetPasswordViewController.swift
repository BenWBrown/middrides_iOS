//
//  resetPasswordViewController.swift
//  middrides
//
//  Created by Ben Brown on 2/15/16.
//  Copyright © 2016 Ben Brown. All rights reserved.
//

import Parse
import UIKit

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    
    // String constants
    let emailNotFoundMessage = "Seems like that email isn't registered. Please enter a valid email";
    let enterValidEmailMessage = "Please enter a valid email address";
    let resetEmailSentMessage = "We have sent you a password reset email. Please check your Middlebury email to reset your password";
    let genericErrorMessage = "An error happened. Please try again.";
    let noInternetMessage = "No Internet connection is available. Please connect to the internet and try again.";
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        emailTextField?.delegate = self;
        emailTextField?.autocorrectionType = .No;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resetButtonPressed(sender: UIButton) {
        // If not connected to internet, inform user and do not attempt to reset
        if (!Connectivity.isConnectedToNetwork()){
            self.displayPopUpMessage("No Internet", message: noInternetMessage);
            return;
        }
        
        
        let email:String? = emailTextField.text;
        
        // Disallow blank emails
        if (email != nil && email?.characters.count <= 0){
            self.displayPopUpMessage("Invalid Email", message: enterValidEmailMessage);
            return;
        }
        
        // Check if the user exists
        var query = PFUser.query();
        query?.whereKey("email", equalTo: email!);
        
        query?.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if (error == nil){
                print("no error");
                // If the user exists send a password reset request
                if let results = objects {
                    if (results.count > 0){
                        
                        PFUser.requestPasswordResetForEmailInBackground(email!);
                        
                        if let user = PFUser.currentUser(){
                            PFUser.logOutInBackground();
                        }
                        
                        self.displayPopUpMessageWithBlock("Reset Email Sent", message: self.resetEmailSentMessage, completionBlock: {
                            (alertAction) -> Void in
                            
                            self.performSegueWithIdentifier("resetPasswordViewToLoginView", sender: self)
                        });

                    } else{
                        // Email not found
                        self.displayPopUpMessage("Email Not Found" , message: self.emailNotFoundMessage);
                    }
                }else{
                    //Email not found
                    self.displayPopUpMessage("Email Not Found" , message: self.emailNotFoundMessage);
                }
            }else{
                // Some other error happened.
                self.displayPopUpMessage("Error", message: self.genericErrorMessage);
            }
        }
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
