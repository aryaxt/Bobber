//
//  PhoneVerification.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/10/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class PhoneVerification: PFObject, PFSubclassing {
    
    @NSManaged var user: User
    @NSManaged var phoneNumber: String
    
    public class func parseClassName() -> String {
        return "PhoneVerification"
    }
    
    override public class func load() {
        registerSubclass()
    }
}
