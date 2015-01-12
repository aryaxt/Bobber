//
//  NotificationSettingService.swift
//  Explore
//
//  Created by Aryan on 10/12/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

import Foundation

public class NotificationSettingService {
    
    public func fetchUserNotificationSettings(block: ([UserNotificationSetting]?, NSError?) -> Void) {
        
        PFCloud.callFunctionInBackground("UserNotificationSetting", withParameters: [String: String]()) { result, error in
            if let recievedError = error {
                block(nil, error)
            }
            else {
                var userSettings = [UserNotificationSetting]()
                
                for object in result as [PFObject] {
                    userSettings.append(object as UserNotificationSetting)
                }
                
                block(userSettings, nil)
            }
        }
    }
}
