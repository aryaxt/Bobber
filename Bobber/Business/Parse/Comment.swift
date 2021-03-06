//
//  Comment.swift
//  Explore
//
//  Created by Aryan on 10/18/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

public class Comment: PFObject, PFSubclassing {
    
    @NSManaged var from: User
    @NSManaged var event: Event
    @NSManaged var text: String
	@NSManaged var isSystem: NSNumber
    
    public class func parseClassName() -> String {
        return "Comment"
    }
    
    override public class func initialize() {
        registerSubclass()
    }
}
