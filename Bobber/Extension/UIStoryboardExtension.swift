//
//  StoryboardExtension.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/11/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

extension UIStoryboard {
    
    public class func instantiateViewController <T: UIViewController>(type: T.Type, storyboardIdentifier: String = "Main") -> T {
        let storyboard = UIStoryboard(name: storyboardIdentifier, bundle: nil)
        return storyboard.instantiateViewController(type)
    }
    
    public func instantiateViewController <T: UIViewController>(type: T.Type) -> T {
        let controllerIdentifier = NSStringFromClass(type).pathExtension
        return instantiateViewControllerWithIdentifier(controllerIdentifier) as! T
    }
    
}
