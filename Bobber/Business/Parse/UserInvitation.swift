//
//  UserInvitation.swift
//  Bobber
//
//  Created by Aryan on 1/6/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class UserInvitation: PFObject, PFSubclassing {

    @NSManaged var user: User
    
    public class func parseClassName() -> String {
        return "UserInvitation"
    }
    
    override public class func initialize() {
        registerSubclass()
    }
}
