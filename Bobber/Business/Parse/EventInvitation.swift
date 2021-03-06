//
//  EventInvitation.swift
//  Bobber
//
//  Created by Aryan on 1/6/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class EventInvitation: PFObject, PFSubclassing {
    
    public enum State: String {
        case Pending = "pending"
        case Accepted = "accepted"
        case Declined = "declined"
		case Confirmed = "confirmed"
    }
    
    // Some kind of phone number in case user is not already a member, in order to later assign events to user when joined
    @NSManaged var event: Event
    @NSManaged var from: User
    @NSManaged var to: User?
    @NSManaged var toPhoneNumber: String?
    @NSManaged var state: String
    var stateEnum: State {
        get { return State(rawValue: state)! }
        set { state = newValue.rawValue }
    }
    
    public class func parseClassName() -> String {
        return "EventInvitation"
    }
    
    override public class func initialize() {
        registerSubclass()
    }
}