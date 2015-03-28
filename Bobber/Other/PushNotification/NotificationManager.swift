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
	
	public enum LocalNotificationAction: String {
		case FinilizingNeeded = "finalizingNeeded" // Sent to creator after expiration in order to finalize
		case SuggestLocation = "suggesLocation" // Sent to attendees as a reminder to suggest a location and time
		case InvitationResponseNeeded = "invitationResponseNeeded" // Send to user as a reminder to respond to a notiication
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
	
	public func scheduleEventLocalNotificationForFiniliingEvent(event: Event) {
		
		if let existingNotitication = localNotificationByEventId(event.objectId, action: LocalNotificationAction.FinilizingNeeded) {
			return
		}
		
		let notification = UILocalNotification()
		notification.alertTitle = "Bob Expired"
		notification.alertBody = "Your Bob '\(event.title)' expired, time to pick a location"
		notification.alertAction = "Go to Bob"
		notification.fireDate = event.expirationDate
		notification.userInfo = ["eventId": event.objectId, "action": LocalNotificationAction.FinilizingNeeded.rawValue]
		
		UIApplication.sharedApplication().scheduleLocalNotification(notification)
	}
	
	public func scheduleEventLocalNotificationForLocationSuggestion(event: Event) {
		
		if let existingNotitication = localNotificationByEventId(event.objectId, action: LocalNotificationAction.SuggestLocation) {
			return
		}
		
		let notification = UILocalNotification()
		notification.alertTitle = "Bob is Expiring"
		notification.alertBody = "Your Bob '\(event.title)' is about to expire, hurry and pick a location and time"
		notification.alertAction = "Suggest Location"
		notification.fireDate = event.expirationDate.dateByAddingTimeInterval(NSTimeInterval(60 * 5 * -1))
		notification.userInfo = ["eventId": event.objectId, "action": LocalNotificationAction.SuggestLocation.rawValue]
		
		UIApplication.sharedApplication().scheduleLocalNotification(notification)
	}
	
	public func scheduleEventLocalNotificationForRespondingToEvent(event: Event) {
		
		if let existingNotitication = localNotificationByEventId(event.objectId, action: LocalNotificationAction.InvitationResponseNeeded) {
			return
		}
		
		let notification = UILocalNotification()
		notification.alertTitle = "Bob is Expiring"
		notification.alertBody = "Your Bob '\(event.title)' is about to expire, hurry and respond yes or no"
		notification.alertAction = "Respond"
		notification.fireDate = event.expirationDate.dateByAddingTimeInterval(NSTimeInterval(60 * 5 * -1))
		notification.userInfo = ["eventId": event.objectId, "action": LocalNotificationAction.InvitationResponseNeeded.rawValue]
		
		UIApplication.sharedApplication().scheduleLocalNotification(notification)
	}
	
	public func unscheduleEventNotification(eventId: String, action: LocalNotificationAction? = nil) {
		if let notification = localNotificationByEventId(eventId, action: action) {
			UIApplication.sharedApplication().cancelLocalNotification(notification)
		}
	}
	
	// MARK: - Private -
	
	private func localNotificationByEventId(eventId: String, action: LocalNotificationAction? = nil) -> UILocalNotification? {
		for notification in UIApplication.sharedApplication().scheduledLocalNotifications as [UILocalNotification] {
			if let id = notification.userInfo?["eventId"] as? String {
				if id == eventId {
					
					if action != nil {
						if let actionString = notification.userInfo?["action"] as? String {
							if actionString == action!.rawValue {
								return notification
							}
						}
					}
					else {
						return notification
					}
				}
			}
		}
		
		return nil
	}
	
}
