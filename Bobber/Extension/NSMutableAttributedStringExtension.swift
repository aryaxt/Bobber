//
//  NSAttributedStringExtension.swift
//  Explore
//
//  Created by Aryan on 10/16/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

import Foundation

enum IcomoonIcon: Character {
    case Home =         "\u{E600}"
    case Pencil =       "\u{e602}"
    case Images =       "\u{e605}"
    case Camera =       "\u{e606}"
    case Music =        "\u{e607}"
    case Film =         "\u{e609}"
    case Tags =         "\u{e601}"
    case Phone =        "\u{e603}"
    case AddressBook =  "\u{e604}"
    case Location =     "\u{e608}"
    case Alarm =        "\u{e60a}"
    case Calendar =     "\u{e60b}"
    case Bubbles =      "\u{e60e}"
    case User =         "\u{e60c}"
    case Users =        "\u{e60d}"
    case Remove =       "\u{e60f}"
    case Bookmarks =    "\u{e610}"
    case FullHeart =    "\u{e611}"
    case EmptyHeart =   "\u{e612}"
    case Share =        "\u{e617}"
    case Male =         "\u{e64c}"
}


extension NSMutableAttributedString {
    
    convenience init(icon: IcomoonIcon, iconColor: UIColor, text: String, textColor: UIColor, font: UIFont) {
        self.init(string: "\(icon.rawValue) \(text)", attributes:[NSFontAttributeName: font, NSForegroundColorAttributeName: textColor])
        
        var rangeofIcon = NSMakeRange(0, 2)
        self.addAttribute(NSFontAttributeName, value: UIFont(name: "icomoon", size: font.pointSize)!, range: rangeofIcon)
        self.addAttribute(NSForegroundColorAttributeName, value: iconColor, range: rangeofIcon)
    }
}