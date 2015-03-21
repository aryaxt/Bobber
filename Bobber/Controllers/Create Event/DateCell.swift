//
//  DateCell.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 3/8/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//


class DateCell: UITableViewCell {
	
	@IBOutlet var titleLabel: UILabel!
	
	func configure(date: NSDate) {
		
		titleLabel.attributedText = NSMutableAttributedString(
			icon: .Calendar,
			iconColor: UIColor.lightGrayColor(),
			text: date.eventFormattedDate(),
			textColor: UIColor.darkGrayColor(),
			font: UIFont.boldSystemFontOfSize(14))
	}
}
