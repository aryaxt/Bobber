//
//  ContactsManager.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/11/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

import AddressBook

public class ContactsManager {
    
    public func fetchContacts(completion: ([Contact]?, NSError?)->()) {
        let addressBook : ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        
        ABAddressBookRequestAccessWithCompletion(addressBook) { granted, error in
            
            if granted == true {
                
                var persons = [Contact]()
                let addressBook : ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
                let allContacts : NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
                
                for contactRef: ABRecordRef in allContacts {
                    var firstName = ABRecordCopyValue(contactRef, kABPersonFirstNameProperty).takeUnretainedValue() as? NSString
                    var lastNAme = ABRecordCopyValue(contactRef, kABPersonLastNameProperty).takeUnretainedValue() as? NSString
                    var phoneNumber: NSString?
                    
                    let unmanagedPhones = ABRecordCopyValue(contactRef, kABPersonPhoneProperty)
                    let phones: ABMultiValueRef = Unmanaged.fromOpaque(unmanagedPhones.toOpaque()).takeUnretainedValue() as NSObject as ABMultiValueRef
                    
                    for index in 0..<ABMultiValueGetCount(phones) {
                        let unmanagedPhoneLabel = ABMultiValueCopyLabelAtIndex(phones, index)
                        
                        if unmanagedPhoneLabel != nil {
                            let phoneLabel = Unmanaged.fromOpaque(unmanagedPhoneLabel.toOpaque()).takeUnretainedValue() as NSObject as String
                            
                            if phoneLabel == kABPersonPhoneMobileLabel {
                                let unmanagedPhone = ABMultiValueCopyValueAtIndex(phones, index)
                                phoneNumber = Unmanaged.fromOpaque(unmanagedPhone.toOpaque()).takeUnretainedValue() as NSObject as String
                                break
                            }
                        }

                    }
                    
                    persons.append(Contact(firstName: firstName, lastName: lastNAme, phoneNumber: phoneNumber))
                }
                
                completion(persons, nil)
            }
            else {
                completion(nil, NSError(domain: "Permission Denied", code: 0, userInfo: nil))
            }
        }
    }
    
    public func fetchContactsWithMobileNumber(completion: ([Contact]?, NSError?)->()) {
        
        fetchContacts { contacts, error in
            
            if let anError = error {
                completion(nil, error)
            }
            else {
                completion(contacts!.filter { return $0.phoneNumber != nil }, nil)
            }
        }
    }
    
}

public class Contact {
    
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
    
    init(firstName: String?, lastName: String?, phoneNumber: String?) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
    }
    
}
