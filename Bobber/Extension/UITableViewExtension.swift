//
//  UITableViewExtension.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 3/7/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public extension UITableView {
	
	public func dequeueReusableCellWithType<T: UITableViewCell>(type: T.Type) -> T {
		return dequeueReusableCellWithIdentifier(NSStringFromClass(type).pathExtension) as T
	}
	
	public func deselectRowAnimated(animated: Bool) {
		if let indexPath = indexPathForSelectedRow() {
			deselectRowAtIndexPath(indexPath, animated: animated)
		}
	}
}
