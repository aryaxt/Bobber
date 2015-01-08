//
//  NSDateExtension.swift
//  Explore
//
//  Created by Aryan on 10/18/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

import Foundation

extension NSDate {
    
    func isSameDayAs(date: NSDate) -> Bool {
        return (self.day() == date.day() && self.month() == date.month() && self.year() == date.year())
    }
    
    func day() -> Int {
        var dateComponents = NSCalendar.currentCalendar().components(.DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit, fromDate: self)
        return dateComponents.day;
    }
    
    func month() -> Int {
        var dateComponents = NSCalendar.currentCalendar().components(.DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit, fromDate: self)
        return dateComponents.month;
    }
    
    func year() -> Int {
        var dateComponents = NSCalendar.currentCalendar().components(.DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit, fromDate: self)
        return dateComponents.year;
    }
}