//
//  UIAlertViewExtension.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/25/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

extension UIAlertController {
    
    public class func show(controller: UIViewController, title: String, message: String, cancelButton: String = NSLocalizedString("Ok", comment: "Ok"), completion: ((UIAlertAction!)->())? = nil) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: cancelButton, style: UIAlertActionStyle.Default, handler: nil))
        controller.presentViewController(alert, animated: true, completion: nil)
    }
    
}
