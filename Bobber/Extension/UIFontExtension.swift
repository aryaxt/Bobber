//
//  UIFontExtension.swift
//  Explore
//
//  Created by Aryan on 10/16/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

import Foundation

let StandardFont = "Georgia"
let BoldFont = "Georgia-Bold"

extension UIFont {

    class func tinyFont() -> UIFont {
        return UIFont(name: StandardFont, size: 10)!
    }
    
    class func tinyBoldFont() -> UIFont {
        return UIFont(name: BoldFont, size: 10)!
    }
    
    class func smallFont() -> UIFont {
        return UIFont(name: StandardFont, size: 12)!
    }
    
    class func smallBoldFont() -> UIFont {
        return UIFont(name: BoldFont, size: 12)!
    }
    
    class func mediumFont() -> UIFont {
        return UIFont(name: StandardFont, size: 14)!
    }
    
    class func mediumBoldFont() -> UIFont {
        return UIFont(name: BoldFont, size: 14)!
    }
    
    class func largeFont() -> UIFont {
        return UIFont(name: StandardFont, size: 16)!
    }
    
    class func largeBoldFont() -> UIFont {
        return UIFont(name: BoldFont, size: 16)!
    }
    
    class func extraLargeFont() -> UIFont {
        return UIFont(name: StandardFont, size: 18)!
    }
    
    class func extraLargeBoldFont() -> UIFont {
        return UIFont(name: BoldFont, size: 18)!
    }
    
    private class func fontOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: StandardFont, size: size)!
    }
}