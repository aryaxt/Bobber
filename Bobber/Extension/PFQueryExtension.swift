//
//  PFQueryExtension.swift
//  Explore
//
//  Created by Aryan on 10/13/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

import Foundation

extension PFQuery {
    
    public func findObjectsInBackgroundWithCompletion <T> (type:T.Type, closure: ([T]?, NSError?) -> Void) {
        findObjectsInBackgroundWithBlock { (result, error) in
            if (error != nil) {
                closure(nil, error)
            }
            else {
                var castedResults = [T]()
                
                for object in result {
                    castedResults.append(object as T)
                }
                
                closure(castedResults, nil)
            }
        }
    }
    
    public func findObjectInBackgroundWithCompletion <T> (type:T.Type, closure: (T?, NSError?) -> Void) {
        findObjectsInBackgroundWithBlock { (result, error) in
            if (error != nil) {
                closure(nil, error)
            }
            else {
                if result.count == 1 {
                    var castedObject = result[0] as T
                    closure(castedObject, nil)
                }
                else {
                    closure(nil, NSError(domain: "RetunedMoreThanOneObject", code: 0, userInfo: nil))
                }
            }
        }
    }
}
