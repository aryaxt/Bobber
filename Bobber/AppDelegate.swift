//
//  AppDelegate.swift
//  Bobber
//
//  Created by Aryan on 1/6/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Parse.setApplicationId("JhvF9YgLmKVVhXXn0Qd6MiBp60vKLI6PdcG3LXLi", clientKey: "BG5RqjnGu85pFOrpWpYY099Wmn4fPsWZauJUpJnK");
		
        PFFacebookUtils.initializeFacebook()
		
		AppearanceManager.configureAppearance()
		
		// Start location service
		LocationManager.sharedInstance
		
		// Setup slide menu
		let animator = SlideNavigationContorllerAnimatorScaleAndFade(maximumFadeAlpha: 0.6, fadeColor: UIColor.blackColor(), andMinimumScale: 0.8)
		SlideNavigationController.sharedInstance().leftMenu = MenuViewController.instantiateFromStoryboard()
		SlideNavigationController.sharedInstance().menuRevealAnimationDuration = 0.18
		SlideNavigationController.sharedInstance().menuRevealAnimator = animator
		
		NotificationManager.sharedInstance.registerForPushNotifications()
		
		if let pushNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject: AnyObject] {
			NotificationManager.sharedInstance.handlePushNotification(pushNotification)
		}
		
		if let localNotification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
			NotificationManager.sharedInstance.handleLocalNotification(localNotification)
		}
		
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //PFFacebookUtils.session().close()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication, withSession: PFFacebookUtils.session())
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        NotificationManager.sharedInstance.deviceToken = deviceToken
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println(error)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {

    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        NotificationManager.sharedInstance.handlePushNotification(userInfo)
    }
	
	func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
		NotificationManager.sharedInstance.handleLocalNotification(notification)
	}
	
	func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
		NotificationManager.sharedInstance.handleLocalNotificationAction(identifier, notification: notification, completion: completionHandler)
	}
	
	func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
		NotificationManager.sharedInstance.handlePushNotificationAction(identifier, userInfo: userInfo, completion: completionHandler)
	}
}

