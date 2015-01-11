//
//  LoginViewController.swift
//  Bobber
//
//  Created by Aryan on 1/6/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

import Foundation

class LoginViewController: BaseViewController {
    
    private lazy var userService = UserService()
    
    @IBAction func loginSelected(sender: AnyObject) {
        userService.authenticateWithFacebook { error in
            if error == nil {
                
                if let currentUser = User.currentUser() {
                    
                    if currentUser.isPhoneNumberVerified?.boolValue == true {
                        
                    }
                    else {
                        self.performSegueWithIdentifier("PhoneVerificationViewController", sender: nil)
                    }
                }
            }
            else {
                
            }
        }
    }
}
