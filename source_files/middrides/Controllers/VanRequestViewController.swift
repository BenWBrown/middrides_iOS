//
//  VanRequestViewController.swift
//  middrides
//
//  Created by Ben Brown on 10/25/15.
//  Copyright © 2015 Ben Brown. All rights reserved.
//

import UIKit
import Parse

class VanRequestViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var locationPickerView: UIPickerView!
    @IBOutlet weak var vanRequestButton: UIButton!
    @IBOutlet weak var userLocationPickerView: UIPickerView!
    
    var vanStops = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationPickerView.delegate = self
        locationPickerView.dataSource = self
        userLocationPickerView.delegate = self
        userLocationPickerView.dataSource = self
        loadVanStops()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return vanStops.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return vanStops[row]["name"] as? String
    }
    
    func loadVanStops(){
        let query = PFQuery(className: "Location")
        query.findObjectsInBackgroundWithBlock() { (objects: [PFObject]?, error: NSError?) -> Void in
            if let unwrappedObjects = objects {
                self.vanStops = unwrappedObjects
                self.locationPickerView.reloadAllComponents()
                self.userLocationPickerView.reloadAllComponents()
            }
            //TODO: ERROR HANDLING
        }
    }
    
    @IBAction func requestButtonPressed(sender: UIButton) {
        if let user = PFUser.currentUser() {
            let dateNow = NSDate(timeIntervalSinceNow: 0)
            NSUserDefaults.standardUserDefaults().setObject(dateNow, forKey: "dateSinceLastRequest")
            NSUserDefaults.standardUserDefaults().synchronize()
            vanRequestButton.setTitle("Requesting...", forState: .Normal)
            let request = PFObject(className: "UserRequest")
            user["pendingRequest"] = true
            request["userId"] = user.objectId
            if let _ = locationPickerView { //locationPickerView might be nil in testing
                let locationName = self.vanStops[self.locationPickerView.selectedRowInComponent(0)]["name"]
                request["dstLocation"] = locationName
            } else {
                request["dstLocation"] = "No location selected"
            }
            if let _ = userLocationPickerView { //userLocationPickerView might be nil in testing
                let userLocationName = self.vanStops[self.userLocationPickerView.selectedRowInComponent(0)]["name"]
                request["pickUpLocation"] = userLocationName
            } else {
                request["pickUpLocation"] = "No location selected"
            }
            request["requestTime"] = NSDate(timeIntervalSinceNow: NSTimeInterval(0))
            request["email"] = user["email"]
            request.saveInBackgroundWithBlock() { (success: Bool, error: NSError?) in
                //TODO: handle callback
                if success {
                    user.saveInBackground()
                    self.performSegueWithIdentifier("vanRequestViewToConfirmationView", sender: self)
                    //display success message
                } else {
                    //do something with error
                }
            }
        }
    }
}