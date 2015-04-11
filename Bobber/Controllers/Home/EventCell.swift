//
//  EventCell.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 3/7/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class EventCell: UITableViewCell {
	
	@IBOutlet private weak var eventCreatorImageView: UIImageView!
	@IBOutlet private weak var eventCreatorName: UILabel!
	@IBOutlet private weak var eventNameLabel: UILabel!
	@IBOutlet private weak var eventLocationLabel: UILabel!
	@IBOutlet private weak var eventTimeLabel: UILabel!
	@IBOutlet private weak var eventTimerLabel: UILabel!
	private var event: Event!
	private var timer: NSTimer!
	
	public override func awakeFromNib() {
		super.awakeFromNib()
		
		timer = NSTimer(timeInterval: 1, target: self, selector: "timerTicked", userInfo: nil, repeats: true)
		timer.fire()
		NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
	}
	
	// MARK: - Actions -
	
	func timerTicked() {
		if (event != nil) {
			eventTimerLabel.text = "\(event.expirationDate.timeIntervalSinceNow/60) minutes"
		}
	}
	
	// MARK: - Public -
	
	public func configure(event: Event) {
		self.event = event
		
		eventNameLabel.text = event.title
		eventCreatorName.text = event.creator.firstName
		eventCreatorImageView.setImageWithURL(NSURL(string: event.creator.photoUrl!))
		
		let locationString = (event.location != nil) ? event.location!.formattedAddress : "In Planning"
		eventLocationLabel.attributedText = NSMutableAttributedString(
			icon: .Location ,
			iconColor: UIColor.deepSkyBlue(),
			text: locationString!,
			textColor: UIColor.deepSkyBlue(),
			font: UIFont.smallBoldFont())
		
		let timeString = (event.location != nil) ? event.location!.formattedAddress : "In Planning"
		eventTimeLabel.attributedText = NSMutableAttributedString(
			icon: .Alarm ,
			iconColor: UIColor.deepSkyBlue(),
			text: timeString!,
			textColor: UIColor.deepSkyBlue(),
			font: UIFont.smallBoldFont())
	}
}
