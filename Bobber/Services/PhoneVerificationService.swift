//
//  PhoneVerificationService.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/10/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class PhoneVerificationService {
    
    public func sendPhoneVerificationCode(phoneNumber: String, completion: (NSError?)->()) {
        let phoneVerification = PhoneVerification()
        phoneVerification.user = User.currentUser()
        phoneVerification.phoneNumber = phoneNumber
        
        phoneVerification.saveInBackgroundWithBlock { bool, error in
            completion(error)
        }
    }
    
    public func verifyPhoneVerificationCode(phoneNumber: String, verificationCode: String, completion: (NSError?)->()) {
        let parameters = ["phoneNumber": phoneNumber, "verificationCode": verificationCode]
        
        PFCloud.callFunctionInBackground("VerifyPhoneNumber", withParameters: parameters) { result, error in
        
            // Make sure user phoneNumber field is updated on the client
            User.currentUser().fetchInBackgroundWithBlock() { user, error in
                completion(error)
            }
        }
    }
    
}