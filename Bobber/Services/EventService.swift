//
//  EventService.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/10/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class EventService {
    
    public func fetchEventDetail(eventId: String, completion: (Event?, NSError?)->()) {
        // TODO: Add attendees to event as PFRelation?
        let query = Event.query()
        query.whereKey("objectId", equalTo: eventId)
        query.includeKey("creator")
        query.includeKey("invitations")
        query.findObjectInBackgroundWithCompletion(Event.self, closure: completion)
    }
    
    public func createEvent(event: Event, completion: (NSError?)->()) {
        event.saveInBackgroundWithBlock { bool, error in
            completion(error)
        }
    }
    
    public func invite(event: Event, user: User, completion: (NSError?)->()) {
        invite(event, to: user, toPhoneNumber: nil, completion: completion)
    }
    
    public func invite(event: Event, toPhoneNumber: String, completion: (NSError?)->()) {
        invite(event, to: nil, toPhoneNumber: toPhoneNumber, completion: completion)
    }
    
    public func cancel(event: Event, completion: (NSError?)->()) {
        event.stateEnum = .Canceled
        
        event.saveInBackgroundWithBlock { success, error in
            completion(error)
        }
    }
    
    public func fetchAttendees(event: Event, completion: ([User]?, NSError?)->()) {
        let query = EventInvitation.query()
        query.whereKey("event", equalTo: event)
        query.whereKey("status", equalTo: EventInvitation.Status.Accepted.rawValue)
        query.includeKey("to")
        
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
        query.whereKey("startTime", greaterThan: NSDate())
        query.findObjectsInBackgroundWithCompletion(Event.self, closure: completion)
    }
    
    public func fetchMyAttendingEvents(completion: ([Event]?, NSError?)->()) {
        // TODO: Accepted and pending, use NSPredicate
        let query = EventInvitation.query()
        query.whereKey("to", equalTo: User.currentUser())
        query.whereKey("status", equalTo: EventInvitation.Status.Accepted.rawValue)
        query.whereKey("startDate", greaterThan: NSDate())
        query.includeKey("event")
        
        query.findObjectsInBackgroundWithCompletion(EventInvitation.self) { invitations, error in
            if error == nil {
                var events = invitations!.map { $0.event }
                completion(events, nil)
            }
            else {
                completion(nil, error)
            }
        }
    }
    
    public func addComment(event: Event, text: String, completion: (NSError?)->()) {
        let comment = Comment()
        comment.from = User.currentUser()
        comment.text = text
        comment.event = event
        
        comment.saveInBackgroundWithBlock { success, error in
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
        
        invitee.saveInBackgroundWithBlock { success, error in
            completion(error)
        }
    }

}
