//
//  UserViewController.swift
//  middrides
//
//  Created by Ben Brown on 11/17/15.
//  Copyright © 2015 Ben Brown. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

    let TIME_OUT = 300.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
            //TODO: POP SOME ERROR MESSAGE
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
