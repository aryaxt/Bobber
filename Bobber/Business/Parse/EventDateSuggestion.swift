//
//  EventDateSuggestion.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 2/15/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class EventDateSuggestion: PFObject, PFSubclassing {
	
	@NSManaged var suggester: User
	@NSManaged var event: Event
	@NSManaged var date: NSDate
	
	public class func parseClassName() -> String {
		return "EventDateSuggestion"
	}
	
	override public class func initialize() {
		registerSubclass()
	}
}
