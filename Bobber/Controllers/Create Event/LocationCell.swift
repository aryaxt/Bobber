//
//  PlaceDetailCell.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 3/7/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

class LocationCell: UITableViewCell {
	
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var addressLabel: UILabel!
	
	func configure(location: GoogleAutocompleteLocation) {
		
		nameLabel.attributedText = NSMutableAttributedString(
			icon: .Location,
			iconColor: UIColor.lightGrayColor(),
			text: location.firstTerm,
			textColor: UIColor.darkGrayColor(),
			font: UIFont.boldSystemFontOfSize(14))
		
		addressLabel.text = location.name
	}
	
}
