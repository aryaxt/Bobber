//
//  Friend.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/8/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class Friend: PFObject, PFSubclassing {
    
    public enum Status: String {
        case Pending = "pending"
        case Accepted = "accepted"
        case Declined = "declined"
    }
    
    // Some kind of phone number in case user is not already a member, in order to later assign events to user when joined
    @NSManaged var from: User
    @NSManaged var to: User
    @NSManaged var status: String
    
    public class func parseClassName() -> String {
        return "Friend"
    }
    
    override public class func load() {
        registerSubclass()
    }
}
