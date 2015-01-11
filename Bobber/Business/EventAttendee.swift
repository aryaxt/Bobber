//
//  Invitation.swift
//  Bobber
//
//  Created by Aryan on 1/6/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class EventAttendee: PFObject, PFSubclassing {
    
    public enum State: String {
        case Pending = "pending"
        case Accepted = "accepted"
        case Declined = "declined"
    }
    
    // Some kind of phone number in case user is not already a member, in order to later assign events to user when joined
    @NSManaged var state: String
    @NSManaged var user: User
    @NSManaged var event: Event
    
    public class func parseClassName() -> String {
        return "EventAttendee"
    }
    
    override public class func load() {
        registerSubclass()
    }
}