//
//  NSDictionaryExtension.swift
//  Explore
//
//  Created by Aryan on 10/17/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

import Foundation

extension NSDictionary {
    
    func objectForKeyPath(keyPath: String) -> AnyObject? {
        var result: AnyObject? = self as AnyObject?
        var keys = keyPath.componentsSeparatedByString(".")
        
        for key in keys {
            if let dictionary = result as? NSDictionary {
                result = dictionary[key]
            }
            else {
                println("Invalid keypath was passed")
                return nil
            }
        }
        
        return result
    }
    
}
