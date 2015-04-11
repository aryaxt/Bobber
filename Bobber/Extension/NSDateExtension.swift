//
//  NSDateExtension.swift
//  Explore
//
//  Created by Aryan on 10/18/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

import Foundation

extension NSDate {
    
    public func isSameDayAs(date: NSDate) -> Bool {
        return (self.day() == date.day() && self.month() == date.month() && self.year() == date.year())
    }
    
    public func day() -> Int {
        var dateComponents = NSCalendar.currentCalendar().components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: self)
        return dateComponents.day;
    }
    
    public func month() -> Int {
        var dateComponents = NSCalendar.currentCalendar().components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: self)
        return dateComponents.month;
    }
	
	public func year() -> Int {
		var dateComponents = NSCalendar.currentCalendar().components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: self)
		return dateComponents.year;
	}
    
    public func hour() -> Int {
        var dateComponents = NSCalendar.currentCalendar().components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitHour | .CalendarUnitMinute, fromDate: self)
        return dateComponents.hour;
    }
	
	public func minute() -> Int {
		var dateComponents = NSCalendar.currentCalendar().components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitHour | .CalendarUnitMinute, fromDate: self)
		return dateComponents.minute;
	}
	
	public func eventFormattedDate() -> String {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "HH: mm"
		
		if isSameDayAs(NSDate()) {
			return "Today \(dateFormatter.stringFromDate(self))"
		}
		else {
			return "Tomorrow \(dateFormatter.stringFromDate(self))"
		}
	}
}