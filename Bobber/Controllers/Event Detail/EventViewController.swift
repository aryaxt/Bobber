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
		
		NSNotificationCenter.defaultCenter().addObserverForName(
			NotificationManager.NotificationType.EventComment.rawValue,
			object: nil,
			queue: nil) { note in
				
			// reload if the new comment is not visible, then display a view after the view clicked take user to top of the page
		}
		
		fetchEventInformation()
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
		else if segue.identifier == "ProfileViewController" {
			let indexPath = tableView.indexPathForSelectedRow()
			let destination = segue.destinationViewController as ProfileViewController
			destination.user = comments[indexPath!.row].from
		}
	}
	
    // MARK: - Private -
		
    private func populateEvent() {
		
        titleLabel.text = event.title
		dateLabel.text = event.startTime == nil ? "Time In Planning" : event.startTime?.eventFormattedDate()
		suggestLocationButton.hidden = event.isExpired() ? true : false
		
		if event.location == nil {
			locationLabel.text =  "Location In Planning, expires in \(event.expirationDate)"
		}
		else {
			locationLabel.text = event.location?.formattedAddress
		}
    }
	
	private func fetchEventInformation() {
		eventService.fetchDetail(event.objectId) { [weak self] event, error in
			if let anError = error {
				// Error
			}
			else {
				self?.event = event!
				self?.populateEvent()
			}
		}
		
		eventService.fetchAttendees(event) { [weak self] invitations, error in
			if error == nil {
				if invitations!.count == 0 {
					self?.attendeesLabel.text = "No attendees yet"
				}
				else {
					self?.attendeesLabel.text = ",".join(invitations!.map { $0.to!.firstName })
				}
				
				let myAttendance = invitations!.filter { $0.to!.isCurrent() }.first
				
				// Event is set for final confirmation and attendee should confirm
				if self!.event.stateEnum == .FinalConfirmation && !self!.event.creator.isCurrent() && myAttendance!.stateEnum == .Accepted {
					UIAlertView.showAlert("Final Confirmation", message: "Organizer has picked location and time", buttons: ["YES"], cancelButton: "NO") { alert, index in
						
						let state: EventInvitation.State = index == alert.cancelButtonIndex ? .Declined : .Confirmed
						self!.eventService.respondToInvitation(myAttendance!, state: state) { error in
							
						}
					}
				}
			}
			else {
				
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
	}
	
	// MARK: - Actions -
	
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
			return shouldShowSuggestedLocations() ? suggestedLocations.count : 0;
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
			return shouldShowSuggestedLocations() ? "Suggested Locations" : nil
		}
		else {
			return "Comments"
		}
	}
	
	public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.section == 0 {
			
			let suggestion = suggestedLocations[indexPath.row]
			
			 //Creator finalizing event
			if event.isExpired() && event.creator.isCurrent() {

				UIActionSheet.showInView(
					view,
					withTitle: "Are you sure you want to pick this location as the final event location?",
					cancelButtonTitle: "No",
					destructiveButtonTitle: nil,
					otherButtonTitles: ["Yes"]) { [weak self] actionSheet, index in
						
						if index != actionSheet.cancelButtonIndex {
							self!.eventService.senfForFinalConfirmation(self!.event, location: suggestion.location) { error in
								
							}
						}
				}
			}
			else if event.stateEnum == .Initial {
				
				UIActionSheet.showInView(
					view,
					withTitle: "Are you sure you want to suggest this location?",
					cancelButtonTitle: "No",
					destructiveButtonTitle: nil,
					otherButtonTitles: ["Yes"]) { [weak self] actionSheet, index in
						
						if index != actionSheet.cancelButtonIndex {
							self!.eventService.suggestLocation(self!.event, location: suggestion.location) { [weak self] suggestion, error in
								
							}
						}
				}
				
			}
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
	
	// MARK: - Private -
	
	private func shouldShowSuggestedLocations() -> Bool {
		if event.stateEnum == .Initial ||
			(event.isExpired() && event.creator.isCurrent()) {
			return true
		}
		
		return false
	}
	
}
