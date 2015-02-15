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
    
    // MARK: - ViewController -
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForLoggedInUser()
    }
    
    // MARK: - Actions -
    
    @IBAction func loginSelected(sender: AnyObject) {
        userService.authenticateWithFacebook { error in
            if error == nil {
                self.checkForLoggedInUser()
            }
            else {
                UIAlertView.show(self, title: "Error", message: error!.localizedDescription)
            }
        }
    }
    
    // MARK: - Private -
    
    private func checkForLoggedInUser() {
        if let currentUser = User.currentUser() {
            
            if currentUser.phoneNumber != nil {
                PushNotificationManager.sharedInstance.tryRegisterDeviceTokenWithParse()
                BobberNavigationController.sharedInstance().applyLoggedInState()
            }
            else {
                self.performSegueWithIdentifier("PhoneVerificationViewController", sender: nil)
            }
        }
    }
}
