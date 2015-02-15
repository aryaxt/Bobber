//
//  PFQueryExtension.swift
//  Explore
//
//  Created by Aryan on 10/13/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

import Foundation

extension PFQuery {
    
    public func findObjectsInBackgroundWithCompletion <T> (type:T.Type, completion: ([T]?, NSError?) -> Void) {
        findObjectsInBackgroundWithBlock { (result, error) in
            if (error != nil) {
                completion(nil, error)
            }
            else {
                var castedResults = [T]()
                
                for object in result {
                    castedResults.append(object as T)
                }
                
                completion(castedResults, nil)
            }
        }
    }
    
    public func findObjectInBackgroundWithCompletion <T> (type:T.Type, completion: (T?, NSError?) -> Void) {
        findObjectsInBackgroundWithBlock { (result, error) in
            if (error != nil) {
                completion(nil, error)
            }
            else {
                if result.count == 1 {
                    var castedObject = result[0] as T
                    completion(castedObject, nil)
                }
                else {
                    completion(nil, NSError(domain: "RetunedMoreThanOneObject", code: 0, userInfo: nil))
                }
            }
        }
    }
}
