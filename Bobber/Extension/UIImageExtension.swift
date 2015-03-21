//
//  UIImageExtension.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/10/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

extension UIImage {

	public class func imageWithIcon(icon: Icomoon, iconColor: UIColor, backgroundColor: UIColor, fontSize: CGFloat, imageSize: CGSize) -> UIImage {
		return imageWithIcon("\(icon.rawValue)", iconColor: iconColor, backgroundColor: backgroundColor, fontSize: fontSize, imageSize: imageSize)
	}
	
	public class func imageWithIcon(iconString: String, iconColor: UIColor, backgroundColor: UIColor, fontSize: CGFloat, imageSize: CGSize) -> UIImage {
        
        let font = UIFont.iconFont(fontSize)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraph.alignment = .Center
		
		let attributes = [
			NSFontAttributeName: font,
			NSForegroundColorAttributeName: iconColor,
			NSParagraphStyleAttributeName: paragraph]
		
		let attributedString = NSAttributedString(string: iconString, attributes: attributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false , 0.0)
        attributedString.drawInRect(CGRectMake(0, 0, imageSize.width, imageSize.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
	
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
