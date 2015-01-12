//
//  NSAttributedStringExtension.swift
//  Explore
//
//  Created by Aryan on 10/16/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

extension NSMutableAttributedString {
    
    convenience init(icon: Icomoon, iconColor: UIColor, text: String, textColor: UIColor, font: UIFont) {
        self.init(string: "\(icon.rawValue) \(text)", attributes:[NSFontAttributeName: font, NSForegroundColorAttributeName: textColor])
        
        var rangeofIcon = NSMakeRange(0, 2)
        self.addAttribute(NSFontAttributeName, value: UIFont(name: "icomoon", size: font.pointSize)!, range: rangeofIcon)
        self.addAttribute(NSForegroundColorAttributeName, value: iconColor, range: rangeofIcon)
    }
}