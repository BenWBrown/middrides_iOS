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
    
    @IBOutlet weak var requestVanButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var requestInfoLabel: UILabel!
    
    var hiddenControls: Bool = false {
        didSet {
            cancelButton.hidden = hiddenControls
            requestInfoLabel.hidden = hiddenControls
            if !hiddenControls {
                requestInfoLabel.text = "" //just in case the following fails
                if let user = PFUser.currentUser() {
                    if let userId = user.objectId {
                        let query = PFQuery(className: "UserRequest")
                        query.whereKey("userId", equalTo: userId)
                        query.findObjectsInBackgroundWithBlock() { (objects: [PFObject]?, error: NSError?) -> Void in
                            if let unwrappedObjects = objects {
                                let object = unwrappedObjects[0]
                                let name = object["pickUpLocation"] as! String
                                self.requestInfoLabel.text = "Your van is en route to\n" + name
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = PFUser.currentUser() {
            if let pendingRequest = user["pendingRequest"] as? Bool {
                if pendingRequest {
                    hiddenControls = false
                } else {
                    hiddenControls = true
                }
            } else {
                hiddenControls = true
            }
        }

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

    
    //TODO: BACKEND ADJUSTMENTS
    @IBAction func cancelRequestButtonPressed(sender: UIButton) {
        var locationID: String?
        
        //update Parse User and UserRequest
        if let user = PFUser.currentUser() {
            user["pendingRequest"] = false
            if let userId = user.objectId {
                let query = PFQuery(className: "UserRequest")
                query.whereKey("userId", equalTo: userId)
                query.findObjectsInBackgroundWithBlock() { (objects: [PFObject]?, error: NSError?) -> Void in
                    if let unwrappedObjects = objects {
                        for object in unwrappedObjects {
                            locationID = object["locationID"] as? String
                            object.deleteEventually()
                        }
                    }
                }
            }
            user.saveInBackground()
        }
        
        //update Parse LocationStatus
        if let unwrappedLocationID = locationID {
            let query = PFQuery(className: "LocationStatus")
            query.whereKey("objectId", equalTo: unwrappedLocationID)
            query.findObjectsInBackgroundWithBlock() { (objects: [PFObject]?, error: NSError?) -> Void in
                if let unwrappedObjects = objects {
                    if (unwrappedObjects[0]["passengersWaiting"] as! Int) > 0 {
                        let numPassengers = unwrappedObjects[0]["passengersWaiting"] as! Int
                        unwrappedObjects[0]["passengersWaiting"] = numPassengers + 1
                    }
                    unwrappedObjects[0].saveInBackground()
                }
            }
        }
        
        //display message
        let alertController = UIAlertController(title: "test", message: "test", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertController, animated: false, completion: nil)
        hiddenControls = true
        //TODO: make UI react
    }
    
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock() { (error: NSError?) -> Void in
            self.performSegueWithIdentifier("userViewToLoginView", sender: self)
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
