//
//  SlideFromTopSegue.swift
//  middrides
//
//  Created by Ben Brown on 2/18/16.
//  Copyright © 2016 Ben Brown. All rights reserved.
//

import UIKit

class SlideFromTopSegue: UIStoryboardSegue {
    
    // ----- copied from http://www.appcoda.com/custom-segue-animations/ ----
    override func perform() {
        // Assign the source and destination views to local variables.
        let firstVCView = self.sourceViewController.view as UIView!
        let secondVCView = self.destinationViewController.view as UIView!
        
        // Get the screen width and height.
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        // Specify the initial position of the destination view.
        secondVCView.frame = CGRectMake(0, -screenHeight, screenWidth, screenHeight)
        
        // Access the app's key window and insert the destination view above the current (source) one.
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(secondVCView, aboveSubview: firstVCView)
        
        // Animate the transition.
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            firstVCView.frame = CGRectMake(0, screenHeight, screenWidth, screenHeight)
            secondVCView.frame = CGRectMake(0, 0, screenWidth, screenHeight)
            
            }) { (Finished) -> Void in
                self.sourceViewController.presentViewController(self.destinationViewController as UIViewController,
                    animated: false,
                    completion: nil)
        }
    }

}
