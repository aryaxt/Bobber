//
//  EventInvitation.swift
//  Bobber
//
//  Created by Aryan on 1/6/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class EventInvitation: PFObject, PFSubclassing {
    
    public enum Status: String {
        case Pending = "pending"
        case Accepted = "accepted"
        case Declined = "declined"
		case AwaitingConfirmation = "awaitingConfirmation"
		case Confirmed = "confirmed"
    }
    
    // Some kind of phone number in case user is not already a member, in order to later assign events to user when joined
    @NSManaged var event: Event
    @NSManaged var from: User
    @NSManaged var to: User?
    @NSManaged var toPhoneNumber: String?
    @NSManaged var status: String
    var statusEnum: Status {
        get { return Status(rawValue: status)! }
        set { status = newValue.rawValue }
    }
    
    public class func parseClassName() -> String {
        return "EventInvitation"
    }
    
    override public class func load() {
        registerSubclass()
    }
}