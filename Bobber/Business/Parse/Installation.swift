//
//  Installation.swift
//  Explore
//
//  Created by Aryan on 10/12/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

public class Installation: PFInstallation {
    
    @NSManaged var user: User
    
    override public class func load() {
        registerSubclass()
    }
}