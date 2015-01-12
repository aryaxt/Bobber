//
//  Event.swift
//  Explore
//
//  Created by Aryan on 10/12/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

public class Event: PFObject, PFSubclassing {
    
    public enum State: String {
        case Pending = "pending"
        case Active = "active"
        case Canceled = "canceled"
    }
    
    @NSManaged var title: String
    @NSManaged var detail: String
    @NSManaged var startTime: NSDate
    @NSManaged var endTime: NSDate?
    @NSManaged var allowInvites: NSNumber
    @NSManaged var inviteeCount: NSNumber
    @NSManaged var attendeeCount: NSNumber
    @NSManaged var creator: User
    @NSManaged var location: Location
    @NSManaged var comments: PFRelation
    @NSManaged var photo: PFFile?
    @NSManaged var state: String
    var stateEnum: State {
        get { return State(rawValue: state)! }
        set { state = newValue.rawValue }
    }
    
    public class func parseClassName() -> String {
        return "Event"
    }
    
    override public class func load() {
        registerSubclass()
    }
}
