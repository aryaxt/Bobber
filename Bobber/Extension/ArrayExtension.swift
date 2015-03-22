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
	
	mutating func append(elements: [T]) {
		for item in elements {
			append(item)
		}
	}
	
	/**
	Groups an array of elements by a given key
	Usage: usersArray.groupBy { $0.age } which will result in [Int: [User]]
	
	:param: gourpClosure a closure used to group elements
	
	:returns: Dictionary<Group, Element>
	*/
	func groupBy<G: Hashable>(gourpClosure: (Element) -> G) -> [G: [Element]] {
		var dictionary = [G: [Element]]()
		
		each {
			let key = gourpClosure($0)
			var array = dictionary[key]
			
			if array == nil {
				array = [Element]()
			}
			
			array!.append($0)
			dictionary[key] = array!
		}
		
		return dictionary
	}
	
}
