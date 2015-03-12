//
//  UIViewControllerExtension.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/11/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public extension UIViewController {
	
	public enum BarButtonPosition {
		case Left
		case Right
	}
	
	public func addBarButtonWithTitle(title: String, position: BarButtonPosition, selector: Selector) {
		let button = UIBarButtonItem(title: title, style: .Plain, target: self, action: selector)
		
		if position == .Left {
			self.navigationItem.leftBarButtonItem = button
		}
		else {
			self.navigationItem.rightBarButtonItem = button
		}
	}
	
	public class func instantiateFromStoryboard() -> Self {
		return UIStoryboard.instantiateViewController(self)
	}
    
}
