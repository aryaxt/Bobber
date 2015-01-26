//
//  PushNotificationManager.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/25/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class PushNotificationManager {
    
    private lazy var installationService = InstallationService()
    
    public var deviceToken: NSData? {
        didSet {
            self.tryRegisterDeviceTokenWithParse()
        }
    }
    
    class var sharedInstance: PushNotificationManager {
        struct Singleton {
            static let instance = PushNotificationManager()
        }
        
        return Singleton.instance
    }
    
    public func registerForPushNotifications() {

        if UIApplication.sharedApplication().respondsToSelector(Selector("registerUserNotificationSettings:")) {
            let notificationTypes: UIUserNotificationType = .Alert | .Sound | .Badge
            let userSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(userSettings)
        }
        else {
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(.Alert | .Sound | .Badge)
        }
    }
    
    public func handleNotification(userInfo: [NSObject : AnyObject]) {
        println(userInfo)
    }
    
    public func tryRegisterDeviceTokenWithParse() {
        if User.currentUser() != nil && deviceToken != nil {
            installationService.updateDeviceToken(deviceToken!)
        }
    }
    
}
