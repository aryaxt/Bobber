//
//  UIAlertViewExtension.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 3/21/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

extension UIAlertView {
	
	public class func showAlert(title: String, message: String, cancelButton: String = "Ok", completion: (()->())? = nil) {
		showAlert(title, message: message, buttons: [], cancelButton: cancelButton) { alert, index in
			if completion != nil {
				completion!()
			}
		}
	}
	
	public class func showAlert(title: String, message: String, buttons: [String], cancelButton: String? = nil, completion: UIAlertViewCompletionBlock? = nil) {
		let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: cancelButton)
		
		alert.tapBlock = completion
		
		for buttonTitle in buttons {
			alert.addButtonWithTitle(buttonTitle)
		}
		
		alert.show()
	}
	
}
