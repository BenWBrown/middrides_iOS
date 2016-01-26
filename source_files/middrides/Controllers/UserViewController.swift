//
//  UserViewController.swift
//  middrides
//
//  Created by Ben Brown on 11/17/15.
//  Copyright © 2015 Ben Brown. All rights reserved.
//

import UIKit
import Parse

class UserViewController: UIViewController {

    let TIME_OUT = 000.0
    let ERROR_TITLE = "ERROR"
    let ERROR_MESSAGE = "Time-out message"
    let ACTION_TITLE = "OK"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //function that checks if the user has made a request in the past 300 seconds
    func checkTimeOut() -> Bool {
        var timeSinceLastRequest = NSTimeInterval(TIME_OUT + 1)
        let dateNow = NSDate(timeIntervalSinceNow: 0)
        if let dateSinceLastRequest = NSUserDefaults.standardUserDefaults().objectForKey("dateSinceLastRequest") as? NSDate {
            timeSinceLastRequest = dateNow.timeIntervalSinceDate(dateSinceLastRequest)
        }

        return timeSinceLastRequest > TIME_OUT
    }
    
    @IBAction func requestVanButtonPressed(sender: UIButton) {
        if checkTimeOut() {
            self.performSegueWithIdentifier("userViewToVanRequestView", sender: self)
        } else {
            let alertController = UIAlertController(title: ERROR_TITLE, message: ERROR_MESSAGE, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: ACTION_TITLE, style: .Default, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            //PFPush.subscribeToChannelInBackground(<#T##channel: String##String#>)
        }
    }

    @IBAction func cancelRequestButtonPressed(sender: UIButton) {
        if let user = PFUser.currentUser() {
            user["pendingRequest"] = false
            if let userId = user.objectId {
                let query = PFQuery(className: "UserRequest")
                query.whereKey("userId", equalTo: userId)
                query.findObjectsInBackgroundWithBlock() { (objects: [PFObject]?, error: NSError?) -> Void in
                    if let unwrappedObjects = objects {
                        for object in unwrappedObjects {
                            object.deleteEventually()
                        }
                    }
                }
            }
            user.saveInBackground()
            //TODO: make UI react
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
