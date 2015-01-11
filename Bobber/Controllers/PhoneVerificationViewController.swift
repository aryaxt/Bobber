//
//  PhoneVerificationViewController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/10/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

import Foundation

class PhoneVerificationViewController: BaseViewController {
    
    private lazy var phoneVerificationService = PhoneVerificationService()
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    
    @IBAction func sendVerificationCodeSelected(sender: AnyObject) {
        phoneVerificationService.sendPhoneVerificationCode(txtPhoneNumber.text) { error in
            println(error)
        }
    }
    
}
