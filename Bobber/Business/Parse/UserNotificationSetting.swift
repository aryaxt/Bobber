//
//  UserNotificationSetting.swift
//  Explore
//
//  Created by Aryan on 10/12/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

public class UserNotificationSetting: PFObject, PFSubclassing {
    
    @NSManaged var enabled: NSNumber
    @NSManaged var notificationSetting: UserNotificationSetting
    
    
    public class func parseClassName() -> String {
        return "UserNotificationSetting"
    }
    
    override public class func initialize() {
        registerSubclass()
    }
}