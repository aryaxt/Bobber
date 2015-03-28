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
        let query = Event.query()
        query.whereKey("objectId", equalTo: eventId)
        query.includeKey("creator")
        query.includeKey("invitations")
        query.findObjectInBackgroundWithCompletion(Event.self, completion: completion)
    }
    
	public func createEvent(title: String, expirationDate: NSDate, completion: (Event?, NSError?)->()) {
		let event = Event()
		event.creator = User.currentUser()
		event.stateEnum = .Initial
		event.title = title
		event.expirationDate = expirationDate
		
        event.saveInBackgroundWithBlock { bool, error in
            completion(event, error)
			
			if error == nil {
				NotificationManager.sharedInstance.scheduleEventLocalNotification(event)
			}
        }
    }
    
    public func invite(event: Event, user: User, completion: (NSError?)->()) {
        invite(event, to: user, toPhoneNumber: nil, completion: completion)
    }
    
    public func invite(event: Event, toPhoneNumber: String, completion: (NSError?)->()) {
        invite(event, to: nil, toPhoneNumber: toPhoneNumber, completion: completion)
    }
	
	public func respondToInvitation(eventInvitation: EventInvitation, status: EventInvitation.State, completion: (NSError?)->()) {
		eventInvitation.stateEnum = status
		eventInvitation.saveInBackgroundWithBlock { result, error in
			completion(error)
		}
	}
    
    public func cancel(event: Event, completion: (NSError?)->()) {
        event.stateEnum = .Canceled
        event.saveInBackgroundWithBlock { success, error in
            completion(error)
        }
    }
    
	public func fetchAttendees(event: Event, var page: Int, perPage: Int, completion: ([User]?, NSError?)->()) {
		page-- // UI thinks of first page as 1, data thinks of first page as 0
        let query = EventInvitation.query()
        query.whereKey("event", equalTo: event)
        query.includeKey("to")
		query.limit = perPage
		query.skip = page * perPage
		
		if event.stateEnum == .Initial {
			query.whereKey("status", equalTo: EventInvitation.State.Accepted.rawValue)
		}
		
		// TODO: Handler final confirmes, if event is sent for final confirmation, diplay confirmed instead of accepted
		
        query.findObjectsInBackgroundWithCompletion(EventInvitation.self) { invitations, error in
            if error == nil {
                let users = invitations!.map { $0.to! }
                completion(users, nil)
            }
            else {
                completion(nil, error)
            }
        }
    }
	
    public func fetchMyEvents(completion: ([Event]?, NSError?)->()) {
        let query = Event.query()
        query.whereKey("creator", equalTo: User.currentUser())
        query.whereKey("createdAt", greaterThanOrEqualTo: NSDate().dateByAddingTimeInterval(60 * 60 * 24 * 2 * -1))
        query.findObjectsInBackgroundWithCompletion(Event.self, completion: completion)
    }

    public func fetchMyInvitations(completion: ([EventInvitation]?, NSError?)->()) {
        // TODO: Accepted and pending, use NSPredicate
		// Think about this, what about expiration time?
        let query = EventInvitation.query()
        query.whereKey("to", equalTo: User.currentUser())
		query.includeKey("event")
		query.includeKey("from")
		
		// TODO: Maybe all attending events with accepted status in the future
		// And all pending where expiration has not passed
        
		query.findObjectsInBackgroundWithCompletion(EventInvitation.self, completion: completion)
    }
	
	public func fetchComments(event: Event, var page: Int, perPage: Int, completion: ([Comment]?, NSError?)->()) {
		page-- // UI thinks of first page as 1, data thinks of first page as 0
		let query = Comment.query()
		query.whereKey("event", equalTo: event)
		query.orderByDescending("createdAt")
		query.limit = perPage
		query.skip = page * perPage
		query.includeKey("from")
		query.findObjectsInBackgroundWithCompletion(Comment.self, completion: completion)
	}
	
    public func addComment(event: Event, text: String, completion: (Comment?, NSError?)->()) {
        let comment = Comment()
        comment.from = User.currentUser()
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
		suggestion.suggester = User.currentUser()
		suggestion.event = event
		suggestion.location = location
		
		suggestion.saveInBackgroundWithBlock { success, error in
			completion(suggestion, error)
		}
	}
	
	public func fetchSuggestedLocations(event: Event, completion: ([EventLocationSuggestion]?, NSError?)->()) {
		let query = EventLocationSuggestion.query()
		query.whereKey("event", equalTo: event)
		query.includeKey("location")
		query.findObjectsInBackgroundWithCompletion(EventLocationSuggestion.self, completion: completion)
	}
	
	public func suggestDate(event: Event, date: NSDate, completion: (NSError?)->()) {
		let suggestion = EventDateSuggestion()
		suggestion.suggester = User.currentUser()
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
        invitee.from = User.currentUser()
        invitee.toPhoneNumber = toPhoneNumber
        invitee.to = to
		invitee.stateEnum = .Pending
        
        invitee.saveInBackgroundWithBlock { success, error in
            completion(error)
        }
    }

}
