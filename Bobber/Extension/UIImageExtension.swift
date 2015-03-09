//
//  UIImageExtension.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/10/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

extension UIImage {
    
//	public class func imageWithIcon(icon: Icomoon, iconColor: UIColor, backgroundColor: UIColor, fontSize: CGFloat, imageSize: CGSize) -> UIImage {
//        
//        let font = UIFont(name: "icomoon", size: fontSize)
//        let paragraph = NSMutableParagraphStyle()
//        paragraph.lineBreakMode = NSLineBreakMode.ByWordWrapping
//        paragraph.alignment = .Center
//        
//        let attributedString = NSAttributedString(string: "\(icon.rawValue)", attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: iconColor, NSParagraphStyleAttributeName:paragraph])
//        
//        let size = sizeOfAttributeString(attributedString, maxWidth: maxWidth)
//        UIGraphicsBeginImageContextWithOptions(size, false , 0.0)
//        attributedString.drawInRect(CGRectMake(0, 0, size.width, size.height))
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return image
//    }
	
	public class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
		UIGraphicsBeginImageContext(size)
		let context = UIGraphicsGetCurrentContext()
		CGContextSetFillColorWithColor(context, color.CGColor)
		CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height))
		let image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext()
		
		return image
	}
    
}
