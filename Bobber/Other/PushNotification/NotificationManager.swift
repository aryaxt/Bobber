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
	
	public enum NotificationCategory: String {
		case Respond = "respond"
	}
	
	public enum NotificationAction: String {
		case RespondAccept = "respondAccept"
		case RespondDecline = "respondDecline"
	}
    
    private lazy var installationService = InstallationService()
    
    public var deviceToken: NSData? {
        didSet {
            tryRegisterDeviceTokenWithParse()
        }
    }
    
    class var sharedInstance: NotificationManager {
        struct Singleton {
            static let instance = NotificationManager()
        }
        
        return Singleton.instance
    }
    
    public func registerForPushNotifications() {
		
		// Respond to invite


        if UIApplication.sharedApplication().respondsToSelector(Selector("registerUserNotificationSettings:")) {
			let categories = NSSet(objects: respondToEventNotificationCategory())
			
            let notificationTypes: UIUserNotificationType = .Alert | .Sound | .Badge
            let userSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: categories)
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
	
	public func handlePushNotificationAction(identifier: String?, userInfo: [NSObject: AnyObject]?, completion: ()->()) {
		
	}
	
	public func handleLocalNotification(localNotification: UILocalNotification) {
			
	}
	
    public func tryRegisterDeviceTokenWithParse() {
        if User.currentUser() != nil && deviceToken != nil {
            installationService.updateDeviceToken(deviceToken!)
        }
    }
	
	// MARK: - Local Notifications -
	
	public func scheduleEventLocalNotificationForFinalizingEvent(event: Event) {
		
		if localNotificationsByEventId(event.objectId, action: LocalNotificationAction.FinilizingNeeded).count > 0 {
			return
		}
		
		let notification = UILocalNotification()
		notification.alertTitle = "Bob Expired"
		notification.alertBody = "Your Bob '\(event.title)' expired, time to pick a location"
		notification.alertAction = "Go to Bob"
		notification.soundName = UILocalNotificationDefaultSoundName
		notification.fireDate = event.expirationDate
		notification.userInfo = ["eventId": event.objectId, "action": LocalNotificationAction.FinilizingNeeded.rawValue]
		
		UIApplication.sharedApplication().scheduleLocalNotification(notification)
	}
	
	public func scheduleEventLocalNotificationForLocationSuggestion(event: Event) {
		
		if localNotificationsByEventId(event.objectId, action: LocalNotificationAction.SuggestLocation).count > 0 {
			return
		}
		
		let notification = UILocalNotification()
		notification.alertTitle = "Bob is Expiring"
		notification.alertBody = "Your Bob '\(event.title)' is about to expire, hurry and pick a location and time"
		notification.alertAction = "Suggest Location"
		notification.soundName = UILocalNotificationDefaultSoundName
		notification.fireDate = event.expirationDate.dateByAddingTimeInterval(NSTimeInterval(60 * 5 * -1))
		notification.userInfo = ["eventId": event.objectId, "action": LocalNotificationAction.SuggestLocation.rawValue]
		
		UIApplication.sharedApplication().scheduleLocalNotification(notification)
	}
	
	public func scheduleEventLocalNotificationForRespondingToEvent(event: Event) {
		
		if localNotificationsByEventId(event.objectId, action: LocalNotificationAction.InvitationResponseNeeded).count > 0 {
			return
		}
		
		let notification = UILocalNotification()
		notification.alertTitle = "Bob is Expiring"
		notification.alertBody = "Your Bob '\(event.title)' is about to expire, hurry and respond yes or no"
		notification.alertAction = "Respond"
		notification.soundName = UILocalNotificationDefaultSoundName
		notification.fireDate = event.expirationDate.dateByAddingTimeInterval(NSTimeInterval(60 * 5 * -1))
		notification.userInfo = ["eventId": event.objectId, "action": LocalNotificationAction.InvitationResponseNeeded.rawValue]
		
		UIApplication.sharedApplication().scheduleLocalNotification(notification)
	}
	
	public func unscheduleEventNotification(eventId: String, action: LocalNotificationAction? = nil) {
		for notification in localNotificationsByEventId(eventId, action: action) {
			UIApplication.sharedApplication().cancelLocalNotification(notification)
		}
	}
	
	// MARK: - Private -
	
	private func respondToEventNotificationCategory() -> UIMutableUserNotificationCategory {
		
		let respondYesToEventNotificationAction = UIMutableUserNotificationAction()
		respondYesToEventNotificationAction.activationMode = .Background
		respondYesToEventNotificationAction.title = "Yes"
		respondYesToEventNotificationAction.identifier = NotificationAction.RespondAccept.rawValue
		respondYesToEventNotificationAction.destructive = false
		respondYesToEventNotificationAction.authenticationRequired = false
		
		let respondNoToEventNotificationAction = UIMutableUserNotificationAction()
		respondNoToEventNotificationAction.activationMode = .Background
		respondNoToEventNotificationAction.title = "No"
		respondNoToEventNotificationAction.identifier = NotificationAction.RespondDecline.rawValue
		respondNoToEventNotificationAction.destructive = true
		respondNoToEventNotificationAction.authenticationRequired = false
		
		let respondToEventNotificationCategory = UIMutableUserNotificationCategory()
		respondToEventNotificationCategory.identifier = NotificationCategory.Respond.rawValue
		respondToEventNotificationCategory.setActions([respondYesToEventNotificationAction, respondNoToEventNotificationAction], forContext: .Default)
		
		return respondToEventNotificationCategory
	}
	
	private func localNotificationsByEventId(eventId: String, action: LocalNotificationAction? = nil) -> [UILocalNotification] {
		
		var notifications = [UILocalNotification]()
		
		for notification in UIApplication.sharedApplication().scheduledLocalNotifications as [UILocalNotification] {
			if let id = notification.userInfo?["eventId"] as? String {
				if id == eventId {
					
					if action != nil {
						if let actionString = notification.userInfo?["action"] as? String {
							if actionString == action!.rawValue {
								notifications.append(notification)
							}
						}
					}
					else {
						notifications.append(notification)
					}
				}
			}
		}
		
		return notifications
	}
	
}
