//
//  LoginViewController.swift
//  middrides
//
//  Created by Ben Brown on 10/3/15.
//  Copyright © 2015 Ben Brown. All rights reserved.
//

enum LoginType {
    case User
    case Dispatcher
    case Invalid
}

import UIKit
import Parse
import Bolts

class LoginViewController: UIViewController {
    
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var Username: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //login known user
        var curUser = PFUser.currentUser();
        if (curUser != nil){
            if (curUser!.username == "dispatcher@middlebury.edu"){
                self.performSegueWithIdentifier("loginViewToDispatcherView", sender: self)
            } else {
                //if user
                if checkAnnouncment() {
                    self.performSegueWithIdentifier("loginViewToAnnouncementView", sender: self)
                } else {
                    self.performSegueWithIdentifier("loginViewToVanRequestView", sender: self)
                }
            }
        }
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        var login = validateLoginCredentials(self.Username.text!, password: self.Password.text!)
        PFUser.logInWithUsernameInBackground("myname", password:"mypass") {
            (user: PFUser?, error: NSError?) -> Void in
            if user == nil {
                login = .Invalid;
            }
            switch login{
            case .User:
                if self.checkAnnouncment() {
                    self.performSegueWithIdentifier("loginViewToAnnouncementView", sender: self)
                } else {
                    self.performSegueWithIdentifier("loginViewToVanRequestView", sender: self)
                }
                
            case .Dispatcher:
                self.performSegueWithIdentifier("loginViewToDispatcherView", sender: self)
                
            case .Invalid:
                //display invalid login message
                print("invalid login, username: " + self.Username.text! + " password: " + self.Password.text!);
            }

        }
        
    }
    
    @IBAction func registerButtonPressed(sender: UIButton) {
        print("register button pressed")
    }
    
    func validateLoginCredentials(username: String, password: String) -> LoginType {
        //TODO: give notice if username/password isn't valid
        
        if (username.characters.count <= 15){
            //make sure there username contains string + '@middlebury.edu'
            return .Invalid;
        }
        if ((username.hasSuffix("@middlebury.edu")) == false){
            //make sure we have a valid email
            return .Invalid;
        }
        
        if (password.characters.count < 6){
            //make sure there are 6 characters in a password
            return .Invalid;
        }
        
        
        //TODO: change dispatcher email?
        if (username == "dispatcher@middlebury.edu"){
            return .Dispatcher;
        }
        

        return .User;

    }
    
    func checkAnnouncment() -> Bool {
        return true
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
