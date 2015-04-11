//
//  UIViewExtension.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 3/7/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public extension UIView {
	
	public class func instantiateFromNib<T: UIView>(viewType: T.Type) -> T {
		return NSBundle.mainBundle().loadNibNamed(NSStringFromClass(viewType).pathExtension, owner: nil, options: nil).first as! T
	}
	
	public class func instantiateFromNib() -> Self {
		return instantiateFromNib(self)
	}
	
}
