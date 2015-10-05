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

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        switch validateLoginCredentials() {
        case .User:
            if checkAnnouncment() {
                self.performSegueWithIdentifier("loginViewToAnnouncementView", sender: self)
            } else {
                self.performSegueWithIdentifier("loginViewToVanRequestView", sender: self)
            }
            
        case .Dispatcher:
            self.performSegueWithIdentifier("loginViewToDispatcherView", sender: self)
        
        case .Invalid:
            //display invalid login message
            print("invalid login")
        }
        
    }
    
    @IBAction func registerButtonPressed(sender: UIButton) {
        print("register button pressed")
    }
    
    func validateLoginCredentials() -> LoginType {
        //validate login here
        return .User
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
