//
//  FriendRequestCell.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 3/27/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public protocol FriendRequestCellCellDelegate: class {
	func friendRequestCellDidSelectDecline(cell: FriendRequestCell)
	func friendRequestCellDidSelectAccept(cell: FriendRequestCell)
}

public class FriendRequestCell: UITableViewCell {
	
	@IBOutlet weak var friendRequestLabel: UILabel!
	@IBOutlet weak var declineButton: UIButton!
	@IBOutlet weak var acceptButton: UIButton!
	weak var delegate: FriendRequestCellCellDelegate!
	
	// MARK: - View Methods -
	
	public override func awakeFromNib() {
		super.awakeFromNib()
		
		declineButton.setTitleColor(UIColor.redColor(), forState: .Normal)
		acceptButton.setTitleColor(UIColor.greenColor(), forState: .Normal)
	}
	
	// MARK: - Public -
	
	public func configure(friendRequest: FriendRequest) {
		friendRequestLabel.text = "\(friendRequest.from.firstName) wants to add you"
	}
	
	// MARK: - Actions -
	
	@IBAction func declineSelected(sender: AnyObject) {
		delegate.friendRequestCellDidSelectDecline(self)
	}
	
	@IBAction func acceptSelected(sender: AnyObject) {
		delegate.friendRequestCellDidSelectAccept(self)
	}
	
}
