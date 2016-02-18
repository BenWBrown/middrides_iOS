//
//  PassengerViewController.swift
//  middrides
//
//  Created by Julian Billings on 1/24/16.
//  Copyright © 2016 Ben Brown. All rights reserved.
//

import UIKit
import Parse

class PassengerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var LocationPickerView: UIPickerView!
    
    @IBAction func RequestButtonHandler(sender: AnyObject) {
        handleVanRequest()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        LocationPickerView.dataSource = self
        LocationPickerView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let rideLocations = ["McCullough Student Center", "Track Lot/KDR", "T Lot", "Q Lot", "Adirondack Circle", "Robert A Jones House", "R Lot", "E Lot", "Frog Hollow"]
    
    let rideLocationIDs = ["Ne5gaXjz31", "1HEwOp97xO", "RITAtVGiHi", "R0nSOeGl8u", "6ZyUSzkVwa", "Lh2mBLCbcV", "zmT2PD5f4e", "4n01d0xXf2", "hYOTtMIc6U"]
    
    var req = PFObject(className: "UserRequest")
    
    //TODO: REFACTOR TO NOT USE GLOBAL VARIABLS
    func handleVanRequest() -> Void {
        let index = LocationPickerView.selectedRowInComponent(0)
        let locationName = rideLocations[index]
        req["pickUpLocation"] = rideLocations[index]
        let locationId = rideLocationIDs[index]
        req["locationId"] = locationId
        req["userId"] = PFUser.currentUser()?.objectId
        req["email"] = PFUser.currentUser()?.email
        req.saveInBackgroundWithBlock{
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                NSUserDefaults.standardUserDefaults().setObject(NSDate(timeIntervalSinceNow: 0), forKey: "dateSinceLastRequest")
            } else {
                // There was a problem, check error.description
                print("Error in sending Request")
            }
        }
        if let user = PFUser.currentUser() {
            user["pendingRequest"] = true
            user.saveInBackground()
        }
        
        //update Parse LocationStatus
            let query = PFQuery(className: "LocationStatus")
        query.whereKey("name", equalTo: locationName)
            query.findObjectsInBackgroundWithBlock() { (objects: [PFObject]?, error: NSError?) -> Void in
                if let unwrappedObjects = objects {
                    let numPassengers = unwrappedObjects[0]["passengersWaiting"] as! Int
                    unwrappedObjects[0]["passengersWaiting"] = numPassengers + 1
                    unwrappedObjects[0].saveInBackground()
                }
            }
    }
    
    /*---------------------
    Adapted from http://makeapppie.com/tag/uipickerview-in-swift/
    ---------------------*/
    
    //MARK: - Delegates and data sources
    
    
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rideLocations.count
    }
    
    //MARK: Delegates
//    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return rideLocations[row]
//    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: rideLocations[row], attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
    }
    

    /*--------------
    -----------------*/
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
