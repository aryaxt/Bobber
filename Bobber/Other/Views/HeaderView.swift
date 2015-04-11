//
//  HeaderView.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 4/9/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class HeaderView: UIView {
	
	@IBOutlet private var titleLabel: UILabel!
	
	public override func awakeFromNib() {
		super.awakeFromNib()
		
		layer.borderWidth = 0.4
		layer.borderColor = UIColor.lighterGray().CGColor
		backgroundColor = UIColor.lightestGray()
	}
	
	public func configure(icon: Icomoon, title: String) {
		titleLabel.attributedText = NSMutableAttributedString(
			icon: icon,
			iconColor: UIColor.deepSkyBlue(),
			text: title,
			textColor: UIColor.deepSkyBlue(),
			font: UIFont.smallBoldFont())
	}
	
	public class func height() -> CGFloat {
		return 35
	}
	
}
