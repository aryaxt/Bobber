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
	
	public func scheduleEventLocalNotificationForCreator(event: Event) {
		let notification = UILocalNotification()
		notification.alertTitle = "Bob Expired"
		notification.alertBody = "Your Bob '\(event.title)' expired, time to pick a location"
		notification.alertAction = "Go to Bob"
		notification.fireDate = event.expirationDate
		notification.userInfo = ["eventId": event.objectId, "action": "finalConfiration"]
		
		UIApplication.sharedApplication().scheduleLocalNotification(notification)
	}
	
	public func scheduleEventLocalNotificationForAttendee(event: Event) {
		let notification = UILocalNotification()
		notification.alertTitle = "Bob is Expiring"
		notification.alertBody = "Your Bob '\(event.title)' is about to expire, hurry and pick a location and time"
		notification.alertAction = "Go to Bob"
		notification.fireDate = event.expirationDate.dateByAddingTimeInterval(NSTimeInterval(60 * 5 * -1))
		notification.userInfo = ["eventId": event.objectId, "action": "suggestLocation"]
		
		UIApplication.sharedApplication().scheduleLocalNotification(notification)
	}
	
	public func unscheduleEventNotification(eventId: String) {
		if let notification = localNotificationByEventId(eventId) {
			UIApplication.sharedApplication().cancelLocalNotification(notification)
		}
	}
	
	// MARK: - Private -
	
	private func localNotificationByEventId(eventId: String) -> UILocalNotification? {
		for notification in UIApplication.sharedApplication().scheduledLocalNotifications as [UILocalNotification] {
			if let id = notification.userInfo?["eventId"] as? String {
				if id == eventId {
					return notification
				}
			}
		}
		
		return nil
	}
	
}
