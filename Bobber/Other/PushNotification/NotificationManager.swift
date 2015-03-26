//
//  PushNotificationManager.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/25/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class NotificationManager {
	
	public enum NotificationType: String {
		case EventComment = "eventComment"
		case EventInvite = "eventInvite"
		case FriendRequest = "friendRequest"
		case EventExpired = "eventExpired"
	}
    
    private lazy var installationService = InstallationService()
    
    public var deviceToken: NSData? {
        didSet {
            self.tryRegisterDeviceTokenWithParse()
        }
    }
    
    class var sharedInstance: NotificationManager {
        struct Singleton {
            static let instance = NotificationManager()
        }
        
        return Singleton.instance
    }
    
    public func registerForPushNotifications() {

        if UIApplication.sharedApplication().respondsToSelector(Selector("registerUserNotificationSettings:")) {
            let notificationTypes: UIUserNotificationType = .Alert | .Sound | .Badge
            let userSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(userSettings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        }
        else {
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(.Alert | .Sound | .Badge)
        }
    }
    
    public func handlePushNotification(userInfo: [NSObject : AnyObject]) {
		
		if let type = userInfo["type"] as? String {
			let data = userInfo["data"] as? [NSObject: AnyObject]
			NSNotificationCenter.defaultCenter().postNotificationName(type, object: self, userInfo: data)
		}
    }
	
	public func handleLocalNotification(localNotification: UILocalNotification) {
			
	}
	
    public func tryRegisterDeviceTokenWithParse() {
        if User.currentUser() != nil && deviceToken != nil {
            installationService.updateDeviceToken(deviceToken!)
        }
    }
	
	public func scheduleEventLocalNotification(event: Event) {
		let notification = UILocalNotification()
		notification.alertTitle = "Bob Expired"
		notification.alertBody = "Your Bob '\(event.title)' expired, time to pick a location"
		notification.alertAction = "Go to Bob"
		notification.fireDate = event.expirationDate
		
		UIApplication.sharedApplication().scheduleLocalNotification(notification)
	}
	
}
