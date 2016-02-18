//
//  ConfirmationViewController.swift
//  middrides
//
//  Created by Ben Brown on 2/14/16.
//  Copyright © 2016 Ben Brown. All rights reserved.
//

import UIKit

class ConfirmationViewController: UIViewController {
    @IBOutlet weak var backgroundImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //load background image
        let backgroundImage = UIImage.animatedImageNamed("transparent-", duration: 2.0)
        guard let unwrappedBackgroundImage = backgroundImage else {
            print("ERROR LOADING BACKGROUND IMAGE")
            return
        }
        //backgroundImageView.image = unwrappedBackgroundImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
