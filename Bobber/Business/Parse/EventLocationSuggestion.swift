//
//  EventLocationSuggestion.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 2/15/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class EventLocationSuggestion: PFObject, PFSubclassing {
	
	@NSManaged var suggester: User
	@NSManaged var event: Event
	@NSManaged var location: Location
	
	public class func parseClassName() -> String {
		return "EventLocationSuggestion"
	}
	
	override public class func load() {
		registerSubclass()
	}
}
