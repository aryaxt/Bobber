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
        var dateComponents = NSCalendar.currentCalendar().components(.DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit, fromDate: self)
        return dateComponents.day;
    }
    
    public func month() -> Int {
        var dateComponents = NSCalendar.currentCalendar().components(.DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit, fromDate: self)
        return dateComponents.month;
    }
    
    public func year() -> Int {
        var dateComponents = NSCalendar.currentCalendar().components(.DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit, fromDate: self)
        return dateComponents.year;
    }
}