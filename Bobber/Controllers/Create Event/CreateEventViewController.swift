//
//  CreateEventViewController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/11/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

class CreateEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	enum SearchMode {
		case Location
		case Date
		case None
	}
	
	@IBOutlet weak var notificationView: UIView!
	@IBOutlet weak var questionTextView: UITextView!
	@IBOutlet weak var toolbarView: UIView!
	@IBOutlet weak var locationButton: UIButton!
	@IBOutlet weak var timeButton: UIButton!
	@IBOutlet weak var tableView: UITableView!
	var event = Event()
	var searchMode: SearchMode = .None
	var locations = [GoogleAutocompleteLocation]()
	var selectedLocation: GoogleAutocompleteLocation?
	var dates = [NSDate]()
	var selectedDate: NSDate?
	var requestQueue = NSOperationQueue()
	var searchStartIndex = -1
	lazy var googleService = GoogleLocationService()
    lazy var eventService = EventService()

    // MARK: - UIViewController -
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		questionTextView.text = "Enter your message here to start"
		notificationView.hidden = true
		toolbarView.hidden = true
		toolbarView.backgroundColor = UIColor.whiteSmokeColor()
		toolbarView.layer.borderWidth = 0.6
		toolbarView.layer.borderColor = UIColor.lightGrayColor().CGColor
		
		let locationImage = UIImage.imageWithIcon(.Location,
			iconColor: UIColor.deepSkyBlue(),
			backgroundColor: UIColor.clearColor(),
			fontSize: 20, imageSize:
			locationButton.frame.size)
		
		locationButton.setTitle("", forState: .Normal)
		locationButton.setImage(locationImage, forState: .Normal)
		
		
		let timeImage = UIImage.imageWithIcon(.Calendar,
			iconColor: UIColor.lightPurple(),
			backgroundColor: UIColor.clearColor(),
			fontSize: 20, imageSize:
			locationButton.frame.size)
		
		timeButton.setTitle("", forState: .Normal)
		timeButton.setImage(timeImage, forState: .Normal)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		NSNotificationCenter.defaultCenter().addObserverForName(UITextViewTextDidChangeNotification, object: questionTextView, queue: nil) { [weak self] note in
			
			switch self!.searchMode {
				
			case .Location:
				self!.searchLocation()
				
			case .Date:
				self!.searchDate()
				
			default:
				self!.clearTable()
			}
		}
		
		NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: nil) { [weak self] note in
			
			if let userInfo = note.userInfo {
				
				let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
				let duration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
				let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
				let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
				let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
				
				var toolbarRect = self!.toolbarView.frame
				toolbarRect.origin.x = 0
				toolbarRect.origin.y = toolbarRect.size.height + self!.view.frame.size.height
				toolbarRect.size.width = self!.view.frame.size.width
				toolbarRect.size.height = 44
				self!.toolbarView.frame = toolbarRect
				self!.toolbarView.hidden = false
				
				UIView.animateWithDuration(duration,
					delay: NSTimeInterval(0),
					options: animationCurve,
					animations: { [weak self] in
						
						toolbarRect.origin.y = self!.view.frame.size.height - endFrame!.size.height - toolbarRect.size.height
						self!.toolbarView.frame = toolbarRect
					},
					completion: nil)
			}
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
		notificationView.hidden = false
		
		var ret = notificationView.frame;
		ret.origin.y = notificationView.frame.size.height * -1
		notificationView.frame = ret
		
		UIView.animateWithDuration(0.3,
			animations: { [weak self] in
				ret.origin.y = 0
				self!.notificationView.frame = ret
			},
			completion: { [weak self] finished in
				self!.questionTextView.becomeFirstResponder()
				return
			}
		)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateEventInviteViewController" {
            let destination = segue.destinationViewController as EventInviteViewController
            destination.event = event
        }
    }
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
	
	// MARK: - UITableView Delegate & Datasource -
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if searchMode == .None {
			return 0
		}
		
		return searchMode == .Location ? locations.count : dates.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		if searchMode == .Location {
			let cell = tableView.dequeueReusableCellWithType(LocationCell.self)
			cell.configure(locations[indexPath.row])
			return cell
		}
		else {
			let cell = tableView.dequeueReusableCellWithType(DateCell.self)
			cell.configure(dates[indexPath.row])
			return cell
		}
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		let startIndex = searchStartIndex
		let range = NSMakeRange(startIndex, questionTextView.selectedRange.location - startIndex)
		var newAttributes: NSMutableAttributedString!
		
		if searchMode == .Location {
			
			selectedLocation = locations[indexPath.row]
			newAttributes = NSMutableAttributedString(string: "\(selectedLocation!.firstTerm)")
			let attributes = [NSForegroundColorAttributeName: UIColor.deepSkyBlue()]
			newAttributes.addAttributes(attributes, range: NSMakeRange(0, countElements(selectedLocation!.firstTerm)))
			
		}
		else {
			
			selectedDate = dates[indexPath.row]
			newAttributes = NSMutableAttributedString(string: "\(selectedDate!.eventFormattedDate())")
			let attributes = [NSForegroundColorAttributeName: UIColor.lightPurple()]
			newAttributes.addAttributes(attributes, range: NSMakeRange(0, countElements(selectedDate!.eventFormattedDate())))
		}
		
		let spaceAfterSearchTerm = NSAttributedString(string: " ", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
		newAttributes.appendAttributedString(spaceAfterSearchTerm)
		let existingAttributedString = questionTextView.attributedText.mutableCopy() as NSMutableAttributedString
		existingAttributedString.replaceCharactersInRange(range, withAttributedString: newAttributes)
		questionTextView.attributedText = existingAttributedString;
		searchStartIndex = -1

		clearTable()
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		switch searchMode {
			
		case .Location:
			return "Start typing a location name or address"
			
		case .Date:
			return "Start typing a date"
			
		default:
			return nil
		}
	}
	
    // MARK: - Actions -
	
	@IBAction func locationSelected(sender: AnyObject) {
		searchMode = .Location
		searchStartIndex = questionTextView.selectedRange.location + 1
		addIconToSelectedRangeForMode(.Location)
		tableView.reloadData()
	}
	
	@IBAction func timeSelected(sender: AnyObject) {
		searchMode = .Date
		searchStartIndex = questionTextView.selectedRange.location + 1
		addIconToSelectedRangeForMode(.Date)
		tableView.reloadData()
	}
	
	private func addIconToSelectedRangeForMode(mode: SearchMode) {
		let icon: Icomoon = mode == .Location ? .Location : .Calendar
		let iconColor: UIColor = mode == .Location ? UIColor.deepSkyBlue() : UIColor.lightPurple()
		let iconAttributedString = NSMutableAttributedString(icon: icon, iconColor: iconColor, text: "", textColor: UIColor.whiteColor(), font: questionTextView.font)
		
		let attributedString = questionTextView.attributedText.mutableCopy() as NSMutableAttributedString
		attributedString.insertAttributedString(iconAttributedString, atIndex: questionTextView.selectedRange.location)
		questionTextView.attributedText = attributedString
	}
	
    @IBAction func cancelSelected(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func createEventSelected(sender: AnyObject) {
        event.creator = User.currentUser()
        
        eventService.createEvent(event) { error in
            if error == nil {
                self.performSegueWithIdentifier("CreateEventInviteViewController", sender: self)
            }
            else {
                UIAlertController.show(self, title: "Error", message: "Error creating event")
            }
        }
    }
	
	// MARK: - Private -
	
	private func clearTable() {
		locations.removeAll(keepCapacity: true)
		dates.removeAll(keepCapacity: true)
		tableView.reloadData()
	}
	
	func searchLocation() {
		let locationTextSearch = searchingText()
		
		if countElements(locationTextSearch) >= 3 {
			
			requestQueue.cancelAllOperations()
			
			// TODO: Do a dispatch_after here
			requestQueue.addOperationWithBlock() { [weak self] in
				self!.performLocationSearchWithText(locationTextSearch)
			}
		}
	}
	
	func searchDate() {
		dates.removeAll(keepCapacity: true)
		dates.append(NSDate())
		dates.append(NSDate())
		dates.append(NSDate())
		
		tableView.reloadData()
	}
	
	func searchingText() -> String {
		let text = questionTextView.text as NSString
		var searchText = text.substringWithRange(NSMakeRange(searchStartIndex, questionTextView.selectedRange.location - searchStartIndex))
		return searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
	}
	
	func performLocationSearchWithText(text: String) {
		// TODO: Avoid duplicate text
		googleService.searchLocations(text) { [weak self] locations, error in
			
			if error == nil {
				self?.locations = locations!
				self?.tableView.reloadData()
			}
		}
	}
	
}
