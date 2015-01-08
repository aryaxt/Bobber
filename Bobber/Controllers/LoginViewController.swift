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
            println(error)
        }
    }
}
