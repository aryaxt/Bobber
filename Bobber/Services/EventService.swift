//
//  EventService.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/10/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class EventService {
    
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
    
    public func invite(event: Event, to: User?, toPhoneNumber: String?, completion: (NSError?)->()) {
        let invitee = EventInvitation()
        invitee.event = event
        invitee.from = User.currentUser()
        invitee.toPhoneNumber = toPhoneNumber
        invitee.to = to
        
        invitee.saveInBackgroundWithBlock { success, error in
            completion(error)
        }
    }
    
    public func cancel(event: Event, completion: (NSError?)->()) {
        event.stateEnum = .Canceled
        
        event.saveInBackgroundWithBlock { success, error in
            completion(error)
        }
    }

}
