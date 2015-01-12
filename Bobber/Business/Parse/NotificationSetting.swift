//
//  NotificationSetting.swift
//  Explore
//
//  Created by Aryan on 10/12/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

public class NotificationSetting: PFObject, PFSubclassing {
    
    @NSManaged var name: String
    @NSManaged var detail: String
    @NSManaged var defaultValue: NSNumber

    
    public class func parseClassName() -> String {
        return "NotificationSetting"
    }
    
    override public class func load() {
        registerSubclass()
    }
}