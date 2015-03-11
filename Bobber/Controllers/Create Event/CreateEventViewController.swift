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
	}
	
	var event = Event()
	var searchMode: SearchMode = .Location
	var locations = [GoogleAutocompleteLocation]()
	var selectedLocation: GoogleAutocompleteLocation?
	var dates = [NSDate]()
	var selectedDate: NSDate?
	var requestQueue = NSOperationQueue()
	var searchStartIndex = -1
	lazy var googleService = GoogleLocationService()
    lazy var eventService = EventService()
    @IBOutlet weak var questionTextView: UITextView!
	@IBOutlet var tableView: UITableView!

    // MARK: - UIViewController -
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		questionTextView.text = ""
		questionTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
		questionTextView.layer.borderWidth = 0.6
		questionTextView.backgroundColor = UIColor.whiteColor()
		
		NSNotificationCenter.defaultCenter().addObserverForName(UITextViewTextDidChangeNotification, object: questionTextView, queue: nil) { [weak self] note in
			
			self!.analyzeTextForSearch()
		}
	}
	
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateEventInviteViewController" {
            let destination = segue.destinationViewController as EventInviteViewController
            destination.event = event
        }
    }
	
	// MARK: - UITableView Delegate & Datasource -
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
		
		let startIndex = searchStartIndex - 1
		let range = NSMakeRange(startIndex, questionTextView.selectedRange.location - startIndex)
		var newAttributes: NSMutableAttributedString!
		
		if searchMode == .Location {
			
			selectedLocation = locations[indexPath.row]
			newAttributes = NSMutableAttributedString(string: "\(selectedLocation!.firstTerm) ")
			newAttributes.addAttribute(NSLinkAttributeName, value: selectedLocation!, range: NSMakeRange(0, countElements(selectedLocation!.firstTerm)))
			
		}
		else {
			
			selectedDate = dates[indexPath.row]
			newAttributes = NSMutableAttributedString(string: "\(selectedDate!.description) ")
			newAttributes.addAttribute(NSLinkAttributeName, value: selectedDate!, range: NSMakeRange(0, countElements(selectedDate!.description)))
		}
		
		let existingAttributedString = questionTextView.attributedText.mutableCopy() as NSMutableAttributedString
		existingAttributedString.replaceCharactersInRange(range, withAttributedString: newAttributes)
		questionTextView.attributedText = existingAttributedString;

		clearTable()
	}
	
    // MARK: - Actions -
	
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
	
	private func analyzeTextForSearch() {
		
		func textRepresentsTime(text: String) -> Bool {
			if let regex = NSRegularExpression(pattern: "^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$", options: nil, error: nil) {
				let count = regex.numberOfMatchesInString(text, options: nil, range: NSMakeRange(0, countElements(text)))
			
				return count == 1
			}
			else {
				return false
			}
		}
		
		let text = questionTextView.text as NSString
		var lastCharacter: String?
		
		if text.length == 0 || questionTextView.selectedRange.length != 0 { return }
		
		if questionTextView.selectedRange.location != 0 {
			lastCharacter = text.substringWithRange(NSMakeRange(questionTextView.selectedRange.location-1, 1))
			
			// Last character was @ start searching
			if lastCharacter == "@" {
				searchStartIndex = questionTextView.selectedRange.location
			}
			// @ was removed reset search
			else if searchStartIndex != -1 {
				
				if text.length < searchStartIndex + 1 || text.substringWithRange(NSMakeRange(searchStartIndex-1, 1)) != "@" {
					searchStartIndex = -1
					return
				}
			}
		}
		
		if (searchStartIndex != -1) {
			
			var searchText = text.substringWithRange(NSMakeRange(searchStartIndex, questionTextView.selectedRange.location - searchStartIndex))
			searchText = searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
			
			// 3 because that's the minimum number of character to guess the time before deciding whether it's time or location
			if countElements(searchText) >= 3 {
				
				if textRepresentsTime(searchText) {
					searchMode = .Date
					suggestDatesBasedOnText(searchText)
				}
				else {
					searchMode = .Location
					requestQueue.cancelAllOperations()
					
					// TODO: Do a dispatch_after here
					requestQueue.addOperationWithBlock() { [weak self] in
						self!.performLocationSearchWithText(searchText)
					}
				}
			}
		}
	}
	
	func suggestDatesBasedOnText(text: String) {
		dates.removeAll(keepCapacity: true)
		dates.append(NSDate())
		dates.append(NSDate())
		dates.append(NSDate())
		
		tableView.reloadData()
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
