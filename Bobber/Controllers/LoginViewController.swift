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
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForLoggedInUser()
    }
    
    @IBAction func loginSelected(sender: AnyObject) {
        userService.authenticateWithFacebook { error in
            if error == nil {
                
                self.checkForLoggedInUser()
            }
            else {
                // TODO: Error out
            }
        }
    }
    
    private func checkForLoggedInUser() {
        if let currentUser = User.currentUser() {
            
            if currentUser.phoneNumber != nil {
                BobberNavigationController.sharedInstance().applyLoggedInState()
            }
            else {
                self.performSegueWithIdentifier("PhoneVerificationViewController", sender: nil)
            }
        }
    }
}
