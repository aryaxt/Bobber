//
//  EventService.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/10/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class EventService {
    
    public func fetchDetail(eventId: String, completion: (Event?, NSError?)->()) {
        // TODO: Add attendees to event as PFRelation?
        let query = Event.query()!
        query.whereKey("objectId", equalTo: eventId)
        query.includeKey("creator")
		query.includeKey("location")
        query.findObjectInBackgroundWithCompletion(Event.self, completion: completion)
    }
    
	public func createEvent(title: String, expirationDate: NSDate, completion: (Event?, NSError?)->()) {
		let event = Event()
		event.creator = User.currentUser()!
		event.stateEnum = .Initial
		event.title = title
		event.expirationDate = expirationDate
		
        event.saveInBackgroundWithBlock { bool, error in
            completion(event, error)
			
			if error == nil {
				NotificationManager.sharedInstance.scheduleEventLocalNotificationForFinalizingEvent(event)
			}
        }
    }
    
    public func invite(event: Event, user: User, completion: (NSError?)->()) {
        invite(event, to: user, toPhoneNumber: nil, completion: completion)
    }
    
    public func invite(event: Event, toPhoneNumber: String, completion: (NSError?)->()) {
        invite(event, to: nil, toPhoneNumber: toPhoneNumber, completion: completion)
    }
	
	public func respondToInvitation(eventInvitation: EventInvitation, state: EventInvitation.State, completion: (NSError?)->()) {
		eventInvitation.stateEnum = state
		eventInvitation.saveInBackgroundWithBlock { result, error in
			completion(error)
			
			if error == nil {
				
				if state == .Accepted {
					NotificationManager.sharedInstance.scheduleEventLocalNotificationForLocationSuggestion(eventInvitation.event)
				}
				else if state == .Declined {
					NotificationManager.sharedInstance.unscheduleEventNotification(eventInvitation.event.objectId!)
				}
			}
		}
	}
    
    public func cancel(event: Event, completion: (NSError?)->()) {
        event.stateEnum = .Canceled
        event.saveInBackgroundWithBlock { success, error in
            completion(error)
			
			if error == nil {
				NotificationManager.sharedInstance.unscheduleEventNotification(event.objectId!)
			}
        }
    }
    
	public func fetchAttendees(event: Event, completion: ([EventInvitation]?, NSError?)->()) {
        let query = EventInvitation.query()!
        query.whereKey("event", equalTo: event)
		query.whereKey("status", notEqualTo: EventInvitation.State.Declined.rawValue)
        query.includeKey("to")

		query.findObjectsInBackgroundWithCompletion(EventInvitation.self, completion: completion)
    }
	
    public func fetchMyEvents(completion: ([Event]?, NSError?)->()) {
        let query = Event.query()!
			.whereKey("creator", equalTo: User.currentUser()!)
			.whereKey("createdAt", greaterThanOrEqualTo: NSDate().dateByAddingTimeInterval(60 * 60 * 24 * 2 * -1))
			.includeKey("creator") // TODO: Do i need creator
        query.findObjectsInBackgroundWithCompletion(Event.self, completion: completion)
    }

    public func fetchMyInvitations(completion: ([EventInvitation]?, NSError?)->()) {

		let acceptedQuery = EventInvitation.query()!
			.whereKey("state", equalTo: EventInvitation.State.Accepted.rawValue)
			.whereKey("to", equalTo: User.currentUser()!)
		
		let pendingQuery = EventInvitation.query()!
			.whereKey("state", equalTo: EventInvitation.State.Pending.rawValue)
			.whereKey("event", matchesQuery: Event.query()!.whereKey("expirationDate", greaterThan: NSDate()))
			.whereKey("to", equalTo: User.currentUser()!)
		
		let finalQuery = PFQuery.orQueryWithSubqueries([acceptedQuery, pendingQuery])
			.includeKey("from")
			.includeKey("event")
			.includeKey("event.creator")

		finalQuery.findObjectsInBackgroundWithCompletion(EventInvitation.self) { invitations, error in
		
			completion(invitations, error)
			
			
			if error == nil {
				for invitation in invitations! {
					if invitation.stateEnum == .Pending {
						NotificationManager.sharedInstance.scheduleEventLocalNotificationForRespondingToEvent(invitation.event)
					}
				}
			}
		}
    }
	
	public func fetchInvitationById(id: String, completion: (EventInvitation?, NSError?)->()) {
		EventInvitation.query()!.getObjectInBackgroundWithId(id) { completion($0 as? EventInvitation, $1) }
	}
	
	public func fetchInvitationByEventId(eventId: String, completion: (EventInvitation?, NSError?)->()) {
		
		let event = Event(withoutDataWithObjectId: eventId)
		let query = EventInvitation.query()!
		query.whereKey("to", equalTo: User.currentUser()!)
		query.whereKey("event", equalTo: event)
		query.findObjectsInBackgroundWithCompletion(EventInvitation.self) { invitations, error in
			if error == nil {
				completion(invitations!.first, nil)
			}
			else {
				completion(nil, error)
			}
		}
	}
	
	public func fetchComments(event: Event, var page: Int, perPage: Int, completion: ([Comment]?, NSError?)->()) {
		page-- // UI thinks of first page as 1, data thinks of first page as 0
		let query = Comment.query()!
		query.whereKey("event", equalTo: event)
		query.orderByDescending("createdAt")
		query.limit = perPage
		query.skip = page * perPage
		query.includeKey("from")
		query.findObjectsInBackgroundWithCompletion(Comment.self, completion: completion)
	}
	
	public func fetchCommentById(id: String, completion: (Comment?, NSError?)->()) {
		Comment.query()!.getObjectInBackgroundWithId(id) { completion($0 as? Comment, $1) }
	}
	
    public func addComment(event: Event, text: String, completion: (Comment?, NSError?)->()) {
        let comment = Comment()
        comment.from = User.currentUser()!
        comment.text = text
        comment.event = event
        
        comment.saveInBackgroundWithBlock { success, error in
			if error == nil {
				completion(comment, nil)
			}
			else {
				completion(nil, error)
			}
        }
    }
	
	public func suggestLocation(event: Event, location: Location, completion: (EventLocationSuggestion?, NSError?)->()) {
		let suggestion = EventLocationSuggestion()
		suggestion.suggester = User.currentUser()!
		suggestion.event = event
		suggestion.location = location
		
		suggestion.saveInBackgroundWithBlock { success, error in
			completion(suggestion, error)
			
			if error == nil {
				NotificationManager.sharedInstance.unscheduleEventNotification(event.objectId!, action: .SuggestLocation)
			}
		}
	}
	
	public func fetchSuggestedLocations(event: Event, completion: ([EventLocationSuggestion]?, NSError?)->()) {
		let query = EventLocationSuggestion.query()!
		query.whereKey("event", equalTo: event)
		query.includeKey("location")
		query.findObjectsInBackgroundWithCompletion(EventLocationSuggestion.self, completion: completion)
	}
	
	public func suggestDate(event: Event, date: NSDate, completion: (NSError?)->()) {
		let suggestion = EventDateSuggestion()
		suggestion.suggester = User.currentUser()!
		suggestion.event = event
		suggestion.date = date
		
		suggestion.saveInBackgroundWithBlock { success, error in
			completion(error)
		}
	}
	
	public func senfForFinalConfirmation(event: Event, location: Location, completion: (NSError?)->()) {
		event.location = location
		event.stateEnum = .FinalConfirmation
		event.saveInBackgroundWithBlock { success, error in
			completion(error)
		}
	}
	
    // MARK: - Private -
    
    private func invite(event: Event, to: User?, toPhoneNumber: String?, completion: (NSError?)->()) {
        let invitee = EventInvitation()
        invitee.event = event
        invitee.from = User.currentUser()!
        invitee.toPhoneNumber = toPhoneNumber
        invitee.to = to
		invitee.stateEnum = .Pending
        
        invitee.saveInBackgroundWithBlock { success, error in
            completion(error)
        }
    }

}
