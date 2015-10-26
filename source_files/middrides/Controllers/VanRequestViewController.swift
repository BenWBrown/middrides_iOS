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
    
    var vanStops = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationPickerView.delegate = self
        locationPickerView.dataSource = self
        loadVanStops()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return vanStops.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return vanStops[row]["LocationName"] as? String
    }
    
    func loadVanStops(){
        let query = PFQuery(className: "MiddRidesLocations")
        query.findObjectsInBackgroundWithBlock() { (objects: [PFObject]?, error: NSError?) -> Void in
            if let unwrappedObjects = objects {
                self.vanStops = unwrappedObjects
                self.locationPickerView.reloadAllComponents()
            }
            //TODO: ERROR HANDLING
        }
    }
    
    @IBAction func requestButtonPressed(sender: UIButton) {
        if let user = PFUser.currentUser() {
            let request = PFObject(className: "UserRequest")
            user["PendingRequest"] = true
            //request["objectId"] = "someId"
            if let _ = locationPickerView { //locationPickerView might be nil in testing
                let locationName = self.vanStops[self.locationPickerView.selectedRowInComponent(0)]["LocationName"]
                request["Location_Name"] = locationName
            } else {
                request["Location_Name"] = "No location selected"
            }
            request["RequestTime"] = NSDate(timeIntervalSinceNow: NSTimeInterval(0))
            request["UserEmail"] = user["email"]
            request.saveInBackgroundWithBlock() { (success: Bool, error: NSError?) in
                //TODO: handle callback
                if success {
                    //display success message
                } else {
                    //do something with error
                }
            }
        }
    }
}