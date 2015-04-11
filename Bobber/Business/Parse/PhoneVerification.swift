//
//  PhoneVerification.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/10/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class PhoneVerification: PFObject, PFSubclassing {
    
    @NSManaged var phoneNumber: String
	
	override init() {
		super.init()
	}
    
    public class func parseClassName() -> String {
        return "PhoneVerification"
    }
    
    override public class func initialize() {
        registerSubclass()
    }
}
