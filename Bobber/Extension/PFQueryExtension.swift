//
//  PFQueryExtension.swift
//  Explore
//
//  Created by Aryan on 10/13/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

import Foundation

extension PFQuery {
    
    func findObjectsInBackgroundWithCompletion <T> (type:T.Type, closure: ([T]?, NSError?) -> Void) {
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
    
    func findObjectInBackgroundWithCompletion <T> (type:T.Type, closure: (T?, NSError?) -> Void) {
        findObjectsInBackgroundWithBlock { (result, error) in
            if (error != nil) {
                closure(nil, error)
            }
            else {
                var castedObject = result as T?
                closure(castedObject, nil)
            }
        }
    }
}
