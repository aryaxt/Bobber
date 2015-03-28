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
	
	@IBOutlet private weak var eventNameLabel: UILabel!
	@IBOutlet private weak var eventTimerLabel: UILabel!
	@IBOutlet private weak var declineButton: UIButton!
	@IBOutlet private weak var acceptButton: UIButton!
	public weak var delegate: EventInvitationCellDelegate!
	private var timer: NSTimer!
	private var invitation: EventInvitation!
	
	// MARK: - View Methods -
	
	public override func awakeFromNib() {
		super.awakeFromNib()
		
		timer = NSTimer(timeInterval: 1, target: self, selector: "timerTicked", userInfo: nil, repeats: true)
		timer.fire()
		NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
		declineButton.setTitleColor(UIColor.redColor(), forState: .Normal)
		acceptButton.setTitleColor(UIColor.greenColor(), forState: .Normal)
	}
	
	// MARK: - Actions -
	
	func timerTicked() {
		if (invitation != nil) {
			eventTimerLabel.text = "\(invitation.event.expirationDate.timeIntervalSinceNow/60) minutes"
		}
	}
	
	// MARK: - Public -
	
	public func configure(eventInvitation: EventInvitation) {
		
		invitation = eventInvitation
		
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
