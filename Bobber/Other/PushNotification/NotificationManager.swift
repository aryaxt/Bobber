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
		case Confirm = "confirm"
	}
	
	public enum NotificationAction: String {
		case RespondAccept = "respondAccept"
		case RespondDecline = "respondDecline"
		case ConfirmAccept = "confirmAccept"
		case ConfirmDecline = "confirmDecline"
	}
    
    private lazy var installationService = InstallationService()
	private lazy var eventService = EventService()
    
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
			let categories = NSSet(objects: respondToEventNotificationCategory(), confirmEventNotificationCategory())
			
            let notificationTypes: UIUserNotificationType = .Alert | .Sound | .Badge
            let userSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: categories as Set<NSObject>)
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
		if let dictionary = userInfo?["data"] as? [NSObject: AnyObject] {
			handleNotificationAction(identifier, userInfo: dictionary, completion: completion)
		}
	}
	
	public func handleLocalNotificationAction(identifier: String?, notification: UILocalNotification, completion: ()->()) {
		handleNotificationAction(identifier, userInfo: notification.userInfo, completion: completion)
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
		
		if localNotificationsByEventId(event.objectId!, action: LocalNotificationAction.FinilizingNeeded).count > 0 {
			return
		}
		
		let notification = UILocalNotification()
		notification.alertTitle = "Bob Expired"
		notification.alertBody = "Your Bob '\(event.title)' expired, time to pick a location"
		notification.alertAction = "Go to Bob"
		notification.soundName = UILocalNotificationDefaultSoundName
		notification.fireDate = event.expirationDate
		notification.userInfo = ["id": event.objectId!, "action": LocalNotificationAction.FinilizingNeeded.rawValue]
		
		UIApplication.sharedApplication().scheduleLocalNotification(notification)
	}
	
	public func scheduleEventLocalNotificationForLocationSuggestion(event: Event) {
		
		if localNotificationsByEventId(event.objectId!, action: LocalNotificationAction.SuggestLocation).count > 0 {
			return
		}
		
		let notification = UILocalNotification()
		notification.alertTitle = "Bob is Expiring"
		notification.alertBody = "Your Bob '\(event.title)' is about to expire, hurry and pick a location and time"
		notification.alertAction = "Suggest Location"
		notification.soundName = UILocalNotificationDefaultSoundName
		notification.fireDate = event.expirationDate.dateByAddingTimeInterval(NSTimeInterval(60 * 5 * -1))
		notification.userInfo = ["id": event.objectId!, "action": LocalNotificationAction.SuggestLocation.rawValue]
		notification.category = NotificationCategory.Respond.rawValue
		
		UIApplication.sharedApplication().scheduleLocalNotification(notification)
	}
	
	public func scheduleEventLocalNotificationForRespondingToEvent(event: Event) {
		
		if localNotificationsByEventId(event.objectId!, action: LocalNotificationAction.InvitationResponseNeeded).count > 0 {
			return
		}
		
		let notification = UILocalNotification()
		notification.alertTitle = "Bob is Expiring"
		notification.alertBody = "Your Bob '\(event.title)' is about to expire, hurry and respond yes or no"
		notification.alertAction = "Respond"
		notification.soundName = UILocalNotificationDefaultSoundName
		notification.fireDate = event.expirationDate.dateByAddingTimeInterval(NSTimeInterval(60 * 5 * -1))
		notification.userInfo = ["id": event.objectId!, "action": LocalNotificationAction.InvitationResponseNeeded.rawValue]
		
		UIApplication.sharedApplication().scheduleLocalNotification(notification)
	}
	
	public func unscheduleEventNotification(eventId: String, action: LocalNotificationAction? = nil) {
		for notification in localNotificationsByEventId(eventId, action: action) {
			UIApplication.sharedApplication().cancelLocalNotification(notification)
		}
	}
	
	// MARK: - Private -
	
	private func handleNotificationAction(identifier: String?, userInfo: [NSObject: AnyObject]?, completion: ()->()) {
		if (identifier == nil || userInfo == nil) {
			completion()
			return
		}
		
		if let action = NotificationAction(rawValue: identifier!) {
			
			switch action {
			case .RespondAccept, .RespondDecline:
				if let eventId = userInfo?["id"] as? String {
					eventService.fetchInvitationByEventId(eventId){ [weak self] invitation, error in
						if error == nil {
							let state: EventInvitation.State = action == .RespondAccept ? .Accepted : .Declined
							self!.eventService.respondToInvitation(invitation!, state: state, completion: { error in
								completion()
							})
						}
						else {
							completion();
						}
					}
				}
				
			default:
				completion()
			}
			
		}
		else {
			completion()
		}
	}
	
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
	
	private func confirmEventNotificationCategory() -> UIMutableUserNotificationCategory {
		
		let confirmYesToEventNotificationAction = UIMutableUserNotificationAction()
		confirmYesToEventNotificationAction.activationMode = .Background
		confirmYesToEventNotificationAction.title = "Yes"
		confirmYesToEventNotificationAction.identifier = NotificationAction.ConfirmAccept.rawValue
		confirmYesToEventNotificationAction.destructive = false
		confirmYesToEventNotificationAction.authenticationRequired = false
		
		let confirmNoToEventNotificationAction = UIMutableUserNotificationAction()
		confirmNoToEventNotificationAction.activationMode = .Background
		confirmNoToEventNotificationAction.title = "No"
		confirmNoToEventNotificationAction.identifier = NotificationAction.ConfirmDecline.rawValue
		confirmNoToEventNotificationAction.destructive = true
		confirmNoToEventNotificationAction.authenticationRequired = false
		
		let respondToEventNotificationCategory = UIMutableUserNotificationCategory()
		respondToEventNotificationCategory.identifier = NotificationCategory.Confirm.rawValue
		respondToEventNotificationCategory.setActions([confirmYesToEventNotificationAction, confirmNoToEventNotificationAction], forContext: .Default)
		
		return respondToEventNotificationCategory
	}
	
	private func localNotificationsByEventId(eventId: String, action: LocalNotificationAction? = nil) -> [UILocalNotification] {
		
		var notifications = [UILocalNotification]()
		
		for notification in UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification] {
			if let id = notification.userInfo?["id"] as? String {
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
