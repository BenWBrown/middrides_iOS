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

    let TIME_OUT = 0.0
    let ERROR_TITLE = "ERROR"
    let ERROR_MESSAGE = "Time-out message"
    let ACTION_TITLE = "OK"
    
    @IBOutlet weak var requestVanButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var requestInfoLabel: UILabel!
    
    var hiddenControls: Bool = false {
        // After setting the hiddenControls variable, adjust the rest of the view accordingly
        didSet {
            // view or hide the cancel and request info according to hiddenControls
            cancelButton.hidden = hiddenControls
            requestInfoLabel.hidden = hiddenControls
            
            // If we are making them visible, query Parse for the requested stop location
            // and show that location to the user
            if !hiddenControls {
                requestInfoLabel.text = "We'll notify you when your van is coming!"
            }
        }
    }

    
    var locationName: String?
    
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
        
        // Add a listener to change the info label when dispatcher sends push
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayVanArrivingMessage:", name: "vanArriving", object: nil);

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //function that checks if the user has made a request in the past TIME_OUT seconds
    func checkTimeOut() -> Bool {
        var timeSinceLastRequest = NSTimeInterval(TIME_OUT + 1)
        let dateNow = NSDate(timeIntervalSinceNow: 0)
        if let dateSinceLastRequest = NSUserDefaults.standardUserDefaults().objectForKey("dateSinceLastRequest") as? NSDate {
            timeSinceLastRequest = dateNow.timeIntervalSinceDate(dateSinceLastRequest)
        }
        print(timeSinceLastRequest)
        print(TIME_OUT)
        return timeSinceLastRequest > TIME_OUT
    }
    
    @IBAction func requestVanButtonPressed(sender: UIButton) {
        if checkTimeOut() {
            if hiddenControls {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "requestPending");
                self.performSegueWithIdentifier("userViewToVanRequestView", sender: self)
            } else {
                self.displayPopUpMessage("Error", message: "Cannot make two van requests at the same time")
            }
        } else {
            self.displayPopUpMessage("Error", message: "Cannot make van requests within 5 minutes of each other")
        }
        
    }

    
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
                            var locName = object["pickUpLocation"] as? String
                            locName = locName!.stringByReplacingOccurrencesOfString(" ", withString: "-")
                            locName = locName!.stringByReplacingOccurrencesOfString("/", withString: "-")
                            PFPush.unsubscribeFromChannelInBackground(locName!)
                            object.deleteEventually()
                        }
                    }
                }
            }
            user.saveInBackground()
        }
        
        //update Parse LocationStatus
        if let unwrappedLocationName = self.locationName {
            let query = PFQuery(className: "LocationStatus")
            query.whereKey("name", equalTo: unwrappedLocationName)
            query.findObjectsInBackgroundWithBlock() { (objects: [PFObject]?, error: NSError?) -> Void in
                if let unwrappedObjects = objects {
                    if (unwrappedObjects[0]["passengersWaiting"] as! Int) > 0 {
                        let numPassengers = unwrappedObjects[0]["passengersWaiting"] as! Int
                        unwrappedObjects[0]["passengersWaiting"] = numPassengers - 1
                    }
                    unwrappedObjects[0].saveInBackground()
                }
            }
        }
        
        //Update local variables
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "requestPending");
        
        //display message
        self.displayPopUpMessage("Success", message: "Van request canceled")
        hiddenControls = true
    }
    
    func displayVanArrivingMessage(sender: AnyObject) -> Void{
        if let user = PFUser.currentUser() {
            if let userId = user.objectId {
                let query = PFQuery(className: "UserRequest")
                query.whereKey("userId", equalTo: userId)
                query.findObjectsInBackgroundWithBlock() { (objects: [PFObject]?, error: NSError?) -> Void in
                    if let unwrappedObjects = objects {
                        // Get the stopname of the latest request, and display that to the user
                        let lastRequestIndex = unwrappedObjects.count - 1;
                        let object = unwrappedObjects[lastRequestIndex]
                        let name = object["pickUpLocation"] as! String
                        self.requestInfoLabel.text = "Your van is en route to\n" + name
                        self.locationName = name
                    }
                }
            }
        }
        
        self.cancelButton.hidden = true;
        
        let FIVE_MINUTES:Double = 5 * 60;
        
        runAfterDelay(FIVE_MINUTES){
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "requestPending");
            self.hiddenControls = true;
        };
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        // If the user has requested a van and is trying to logout, they should be informed.
        let logoutConfirmation = UIAlertController(title: "Confirm Logout", message: "Are you sure you want to logout? This will cancel any requests you have placed.", preferredStyle: UIAlertControllerStyle.Alert)
        
        logoutConfirmation.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            // If user confirms logout
            self.cancelRequestButtonPressed(self.cancelButton);
            PFUser.logOutInBackgroundWithBlock() { (error: NSError?) -> Void in
                self.performSegueWithIdentifier("userViewToLoginView", sender: self)
            }
        }))
        
        logoutConfirmation.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            //If user cancels, nothing happens
        }))
        
        presentViewController(logoutConfirmation, animated: true, completion:  nil)
    }
    
    /*
     * Runs a given code block after an n second delay
     */
    func runAfterDelay(delay: NSTimeInterval, block: dispatch_block_t) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)));
        dispatch_after(time, dispatch_get_main_queue(), block);
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
