//
//  AppDelegate.swift
//  middrides
//
//  Created by Ben Brown on 10/3/15.
//  Copyright © 2015 Ben Brown. All rights reserved.
//

import UIKit
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var pushRespController:PushResponseController?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize Parse.
        Parse.setApplicationId("II5Qw9I5WQ5Ezo9mL8TdYj3mEoiSFcdt8GFMAgsm",
            clientKey: "EIepTgb590NQw5DDu1EccT7YvprP2ovLesj1t3Nd");
        
        self.pushRespController = PushResponseController();
        
        /*---------FROM PARSE WEBSITE-----------*/
        
        // Register for Push Notitications
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        if #available(iOS 8.0, *) {
            let types: UIUserNotificationType = [.Alert, .Badge, .Sound]
            let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            let types: UIRemoteNotificationType = [.Alert, .Badge, .Sound]
            application.registerForRemoteNotificationTypes(types)
        }
        
        /*-------------------------------------*/
        
        /*
        if (application.respondsToSelector("registerUserNotificationSettings:")){
            //if iOS8+
            
            let types:UIUserNotificationType = (.Alert | .Badge | .Sound);
            let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil);
            application.registerUserNotificationSettings(settings);
            application.registerForRemoteNotifications();
        } else {
            application.registerForRemoteNotificationTypes(.Alert | .Badge | .Sound);
        }
        */
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    /*---------FROM PARSE WEBSITE-----------*/
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("Called in background");
        self.application(application, didReceiveRemoteNotification: userInfo);
        if(application.applicationState == UIApplicationState.Inactive){
            print("inactive");
        }else if (application.applicationState == UIApplicationState.Background){
            print("background");
        } else{
            print("Active");
        }
        completionHandler(UIBackgroundFetchResult.NewData);
    }
    
    //Handle push notifications
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print(userInfo)
        PFPush.handlePush(userInfo)
        let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        let nextDest = userInfo["location"] as! String
        
        //unsubscribe from necessary channel
        var channelName = nextDest.stringByReplacingOccurrencesOfString(" ", withString: "-")
        channelName = channelName.stringByReplacingOccurrencesOfString("/", withString: "-")
        PFPush.unsubscribeFromChannelInBackground(channelName)
        let msg = "Your van is headed to " + nextDest + " now!"     ;
        
        // create a local notification
        let notification = UILocalNotification()
        notification.alertBody = msg // text that will be displayed in the notification
        notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        // When notification will be fired
        notification.fireDate = NSDate(timeIntervalSinceNow: 5);
        // play default sound
        notification.soundName = UILocalNotificationDefaultSoundName
        // assign a unique identifier to the notification so that we can retrieve it later
        notification.userInfo = ["UUID": userInfo["parsePushId" ]!, ]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        //Save the reference to the notification so we can remove it later
        NSUserDefaults.standardUserDefaults().setObject(userInfo["parsePushId"], forKey: "currentPushId");
        
        //Notify other views that the van is arriving so they update accordingly
        NSNotificationCenter.defaultCenter().postNotificationName("vanArriving", object: nil);
        
        var curView = self.window?.rootViewController
        /*
        'while' loop with presented view controller based on top answer here:
        http://stackoverflow.com/questions/26667009/get-top-most-uiviewcontroller
        */
        while ((curView?.presentedViewController) != nil){
            curView = curView?.presentedViewController
        }
        

        let alert = UIAlertController(title: "MiddRides Notice!", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(okButton)
        
        curView!.presentViewController(alert, animated: true, completion: nil)
        
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
    /*-------------------------------------*/

}

