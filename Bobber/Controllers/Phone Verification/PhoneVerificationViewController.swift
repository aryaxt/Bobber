//
//  PhoneVerificationViewController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/10/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

import Foundation

class PhoneVerificationViewController: BaseViewController {
    
    enum VerificationState {
        case SendVerification
        case VerifyCode
    }
    
    private lazy var phoneVerificationService = PhoneVerificationService()
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtVerificationCode: UITextField!
    @IBOutlet var btnSend: UIButton!
    @IBOutlet var btnVerify: UIButton!
    @IBOutlet var lblDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSend.removeFromSuperview()
        btnVerify.removeFromSuperview()
        txtPhoneNumber.inputAccessoryView = btnSend
        txtVerificationCode.inputAccessoryView = btnVerify

        updateVerificationSate(.SendVerification)
    }
    
    @IBAction func sendVerificationCodeSelected(sender: AnyObject) {
        phoneVerificationService.sendPhoneVerificationCode(txtPhoneNumber.text) { error in
            if error == nil {
                self.updateVerificationSate(.VerifyCode)
            }
            else {
                UIAlertView.show(self, title: "Error", message: "There was a problem sening phone verification")
            }
        }
    }
    
    @IBAction func verifySelected(sender: AnyObject) {
        phoneVerificationService.verifyPhoneVerificationCode(txtPhoneNumber.text, verificationCode: txtVerificationCode.text) { error in
            
            if error == nil {
                BobberNavigationController.sharedInstance().applyLoggedInState()
            }
            else {
                UIAlertView.show(self, title: "Error", message: "Invalid verification code")
            }
        }
    }
    
    private func updateVerificationSate(state: VerificationState) {
    
        if state == .SendVerification {
            txtPhoneNumber.hidden = false
            txtVerificationCode.hidden = true
            lblDescription.text = "Enter your phone number"
            txtPhoneNumber.becomeFirstResponder()
        }
        else if state == .VerifyCode {
            txtPhoneNumber.hidden = true
            txtVerificationCode.hidden = false
            lblDescription.text = "Enter your verification number"
            txtVerificationCode.becomeFirstResponder()
        }
    }
    
}
