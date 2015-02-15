//
//  EventInvitationCell.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 2/14/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

protocol EventInvitationCellDelegate: class {
	func eventInvitationCellDidSelectDecline(cell: EventInvitationCell)
	func eventInvitationCellDidSelectAccept(cell: EventInvitationCell)
}

class EventInvitationCell: UITableViewCell {
	
	@IBOutlet weak var eventNameLabel: UILabel!
	@IBOutlet weak var declineButton: UIButton!
	@IBOutlet weak var acceptButton: UIButton!
	weak var delegate: EventInvitationCellDelegate!
	
	func configure(eventInvitation: EventInvitation) {
		self.eventNameLabel.text = eventInvitation.event.title
	}
	
	// MARK: - Actions -
	
	@IBAction func declineSelected(sender: AnyObject) {
		delegate.eventInvitationCellDidSelectDecline(self)
	}
	
	@IBAction func acceptSelected(sender: AnyObject) {
		delegate.eventInvitationCellDidSelectAccept(self)
	}
}
