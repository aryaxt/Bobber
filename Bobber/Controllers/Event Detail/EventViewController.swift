//
//  EventViewController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/11/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class EventViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, LocationSearchViewControllerDelegate {
	
	@IBOutlet private weak var tableView: UITableView!
	@IBOutlet private weak var titleLabel: UILabel!
	@IBOutlet private weak var locationLabel: UILabel!
	@IBOutlet private weak var dateLabel: UILabel!
	@IBOutlet private weak var attendeesLabel: UILabel!
	@IBOutlet private weak var attendeesScrollView: UIScrollView!
	@IBOutlet private weak var commentTextView: UITextView!
	@IBOutlet private weak var sendCommentButton: UIButton!
	@IBOutlet private weak var suggestLocationButton: UIButton!
    public var event: Event!
    private var comments = [Comment]()
	private var suggestedLocations = [EventLocationSuggestion]()
    private lazy var eventService = EventService()
    
    // MARK: - UIViewController -
    
    override public func viewDidLoad() {
        super.viewDidLoad()
		
		addBarButtonWithTitle("Invite", position: .Right, selector: "inviteSelected:")
		
        populateEvent()
        
        eventService.fetchDetail(event.objectId) { [weak self] event, error in
            if let anError = error {
                // Error
            }
            else {
                self?.event = event!
                self?.populateEvent()
            }
        }
		
		eventService.fetchComments(event, page: 1, perPage: 25) { [weak self] comments, error in
			if error == nil {
				self!.comments.append(comments!)
				self!.tableView.reloadData()
			}
			else {
				UIAlertController.show(self!, title: "Error", message: "Error posting comment")
			}
		}
		
		eventService.fetchAttendees(event, page: 1, perPage: 100) { [weak self] users, error in
			if error == nil {
				if users!.count == 0 {
					self?.attendeesLabel.text = "No attendees yet"
				}
				else {
					self?.attendeesLabel.text = ",".join(users!.map { $0.firstName })
				}
			}
			else {
				
			}
		}
		
		// No need to fetch these if event is already planned to event has a location
		eventService.fetchSuggestedLocations(event) { [weak self] suggestedLocations, error in
			if error == nil {
				self!.suggestedLocations.append(suggestedLocations!)
				self!.tableView.reloadData()
			}
			else {
				UIAlertController.show(self!, title: "Error", message: "Error posting comment")
			}
		}
		
		NSNotificationCenter.defaultCenter().addObserverForName(
			PushNotificationManager.NotificationType.EventComment.rawValue,
			object: nil,
			queue: nil) { note in
				
			// reload if the new comment is not visible, then display a view after the view clicked take user to top of the page
		}
    }
	
	override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "EventInviteViewController" {
			let destination = segue.destinationViewController as UINavigationController
			let inviteViewController = destination.topViewController as EventInviteViewController
			inviteViewController.event = event
		}
		else if segue.identifier == "LocationSearchViewController" {
			let destination = segue.destinationViewController as UINavigationController
			let inviteViewController = destination.topViewController as LocationSearchViewController
			inviteViewController.delegate = self
		}
	}
	
    // MARK: - Private -
		
    private func populateEvent() {
        titleLabel.text = event.title
		locationLabel.text = event.location == nil ? "Location In Planning" : event.location!.formattedAddress
		dateLabel.text = event.startTime == nil ? "Time In Planning" : event.startTime!.eventFormattedDate()
		suggestLocationButton.hidden = event.stateEnum == .Planning ? false : true
    }
	
	// MARK: - Actions -
	
	@IBAction func suggestLocationSelected(sender: AnyObject) {
		
	}
	
	@IBAction func inviteSelected(sender: AnyObject) {
		performSegueWithIdentifier("EventInviteViewController", sender: nil)
	}
	
	@IBAction func sendCommentSelected(sender: AnyObject) {
		commentTextView.resignFirstResponder()
		
		eventService.addComment(event, text: commentTextView.text) { [weak self] comment, error in
			if error == nil {
				self?.commentTextView.text = nil
				
				self?.tableView.beginUpdates()
				self?.comments.insert(comment!, atIndex: 0)
				self?.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: .Automatic)
				self?.tableView.endUpdates()
			}
			else {
				UIAlertController.show(self!, title: "Error", message: "Error posting comment")
			}
		}
	}
	
	// MARK: - UITableView Delegate & Datasource -
	
	public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	
	public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return suggestedLocations.count;
		}
		else {
			return comments.count
		}
	}
	
	public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCellWithIdentifier("SuggestedLocationCell") as UITableViewCell
			let suggestedLocation = suggestedLocations[indexPath.row]
			cell.textLabel?.text = suggestedLocation.location.formattedAddress
			return cell
		}
		else {
			let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as UITableViewCell
			let comment = comments[indexPath.row]
			cell.textLabel?.text = comment.from.firstName
			cell.detailTextLabel?.text = comment.text
			cell.imageView?.setImageWithURL(NSURL(string: comment.from.photoUrl!), placeholderImage: UIImage(named: "placeholder"))
			return cell
		}
	}
	
	public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return "Suggested Locations"
		}
		else {
			return "Comments"
		}
	}
	
	public func scrollViewDidScroll(scrollView: UIScrollView) {
		commentTextView.resignFirstResponder()
	}
	
	// MARK: - LocationSearchViewControllerDelegate -
	
	func locationSearchViewController(controller: LocationSearchViewController, didSelectLocation autocompleteLocation: GoogleAutocompleteLocation) {
		dismissViewControllerAnimated(true, completion: nil)
		
		eventService.suggestLocation(event, location: Location(autocompleteLocation)) { [weak self] suggestion, error in
			
			if error == nil {
				self!.tableView.beginUpdates()
				self!.suggestedLocations.insert(suggestion!, atIndex: 0)
				self!.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
				self!.tableView.endUpdates()
			}
			else {
				
			}
		}
	}
	
	func locationSearchViewControllerDidCancel(controller: LocationSearchViewController) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
}
