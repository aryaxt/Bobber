//
//  ArrayExtension.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 2/14/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

extension Array {
	
	func each (closure: (Element)->()) {
		for element in self {
			closure(element)
		}
	}
	
}
