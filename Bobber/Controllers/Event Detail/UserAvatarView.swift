//
//  UserAvatar.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 3/21/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class UserAvatarView: UIView {
	
	@IBOutlet private var userImageView: UIImageView!
	@IBOutlet private var userNameLabel: UILabel!
	
	public func configure(user: User) {
		userNameLabel.text = user.firstName
		// TODO: Add placeholder
		userImageView.setImageWithURL(NSURL(fileURLWithPath: user.photoUrl!), placeholderImage: UIImage(named: "placeholder"))
	}
}
