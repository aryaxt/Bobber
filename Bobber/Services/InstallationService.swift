//
//  InstallationService.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/25/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class InstallationService {
    
    public func updateDeviceToken(deviceToken: NSData) {
        
        let installation = Installation.currentInstallation()
        installation.user = User.currentUser()
        installation.setDeviceTokenFromData(deviceToken)
		installation.saveInBackgroundWithBlock { result, error in }
    }
    
}
