//
//  User.swift
//  Explore
//
//  Created by Aryan on 10/12/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

public class User: PFUser, PFSubclassing {
    
    public enum Gender: Int {
        case Other = 0
        case Male = 1
        case Female = 2
    }

    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var socialId: String?
    @NSManaged var photoUrl: String?
    @NSManaged var phoneNumber: String?
    @NSManaged var birthday: NSDate?
    @NSManaged var gender: NSNumber?
    
    override public class func load() {
        registerSubclass()
    }
	
	public func isCurrent() -> Bool {
		return objectId == User.currentUser().objectId
	}
    
}
