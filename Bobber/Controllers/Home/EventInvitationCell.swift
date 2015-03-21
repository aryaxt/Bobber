//
//  EventInvitationCell.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 2/14/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public protocol EventInvitationCellDelegate: class {
	func eventInvitationCellDidSelectDecline(cell: EventInvitationCell)
	func eventInvitationCellDidSelectAccept(cell: EventInvitationCell)
}

public class EventInvitationCell: UITableViewCell {
	
	@IBOutlet weak var eventNameLabel: UILabel!
	@IBOutlet weak var declineButton: UIButton!
	@IBOutlet weak var acceptButton: UIButton!
	weak var delegate: EventInvitationCellDelegate!
	
	// MARK: - View Methods -
	
	public override func awakeFromNib() {
		super.awakeFromNib()
		
		declineButton.setTitleColor(UIColor.redColor(), forState: .Normal)
		acceptButton.setTitleColor(UIColor.greenColor(), forState: .Normal)
	}
	
	// MARK: - Public -
	
	public func configure(eventInvitation: EventInvitation) {
		
		let defaultAttributes = [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont.systemFontOfSize(14)]
		let fromAttributes = [NSForegroundColorAttributeName: UIColor.blueColor()]
		let string = "\(eventInvitation.from.firstName) wants to \(eventInvitation.event.title)"
		let attributedString = NSMutableAttributedString(string: string, attributes: defaultAttributes)
		attributedString.addAttributes(fromAttributes, range: NSMakeRange(0, countElements(eventInvitation.from.firstName)))
		eventNameLabel.attributedText = attributedString
	}
	
	// MARK: - Actions -
	
	@IBAction func declineSelected(sender: AnyObject) {
		delegate.eventInvitationCellDidSelectDecline(self)
	}
	
	@IBAction func acceptSelected(sender: AnyObject) {
		delegate.eventInvitationCellDidSelectAccept(self)
	}
}
