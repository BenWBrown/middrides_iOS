//
//  resetPasswordViewController.swift
//  middrides
//
//  Created by Ben Brown on 2/15/16.
//  Copyright © 2016 Ben Brown. All rights reserved.
//

import UIKit

class resetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resetButtonPressed(sender: UIButton) {
        //TODO: SHERIF ACTUALLY DO YOUR CODE HERE
        
        
        //segue back to login view
        self.performSegueWithIdentifier("resetPasswordViewToLoginView", sender: self)
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
