//
//  HomeViewController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/11/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class HomeViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, EventInvitationCellDelegate, FriendRequestCellCellDelegate, SlideNavigationControllerDelegate, CreateEventViewControllerDelegate {
	
	public enum Section: Int {
		case FriendRequest = 0
		case EventRequests = 1
		case Events = 2
	}
	
    @IBOutlet private weak var tableView: UITableView!
    private lazy var eventService = EventService()
	private lazy var friendService = FriendService()
    private var events = [Event]()
	private var invitations = [EventInvitation]()
	private var friendRequests = [FriendRequest]()
    
    // MARK: - UIViewController -
    
    override public func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.tableFooterView = UIView()
		tableView.estimatedRowHeight = 100.0
		
		addBarButtonWithTitle("Create", position: .Right, selector: "createEventSelected:")

		fetchAndPopulateData()
		
		NSNotificationCenter.defaultCenter().addObserverForName(
			NotificationManager.NotificationType.EventInvite.rawValue,
			object: nil,
			queue: nil) { [weak self] note in
				
				// TODO: Fetch by id instead?
				self?.fetchAndPopulateData()
				return
		}
	}
	
	override public func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		tableView.deselectRowAnimated(true)
	}
	
	public override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		tableView.addPullToRefreshWithActionHandler() { [weak self] in
			self?.fetchAndPopulateData()
			return
		}
	}
	
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EventViewController" {
            let destination = segue.destinationViewController as! EventViewController
            let event = events[tableView.indexPathForSelectedRow()!.row]
            destination.event = event
        }
		else if segue.identifier == "CreateEventViewController" {
			let navigationController = segue.destinationViewController as! UINavigationController
			let destination = navigationController.topViewController as! CreateEventViewController
			destination.delegate = self
		}
    }
	
	// MARK: - SlideNavigationControllerDelegate -
	
	public func slideNavigationControllerShouldDisplayLeftMenu() -> Bool {
		return true
	}
	
    // MARK: - UITableView Delegate & Datasource -
	
	public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 3
	}
	
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section(rawValue: section)! {
		case .FriendRequest:
			return friendRequests.count
			
		case .EventRequests:
			return invitations.count
			
		case .Events:
			return events.count
		}
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		return cellForRowAtIndexPath(indexPath)
    }
	
	public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = HeaderView.instantiateFromNib()
		
		switch Section(rawValue: section)! {
		case .FriendRequest:
			header.configure(.Users, title: "Friend Requests")
			
		case .EventRequests:
			header.configure(Icomoon.Alarm, title: "Pending Requests")
			
		case .Events:
			header.configure(Icomoon.Calendar, title: "Your Events")
		}
		
		return header
	}
	
//	public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//		let cell = cellForRowAtIndexPath(indexPath)
//		cell.contentView.setNeedsLayout()
//		cell.contentView.layoutIfNeeded()
//		let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
//		println(size)
//		return size.height
//	}
	
	public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return HeaderView.height()
	}
	
	// MARK: - Private -
	
	public func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
		
		switch Section(rawValue: indexPath.section)! {
		case .FriendRequest:
			let cell = tableView.dequeueReusableCellWithType(FriendRequestCell.self)
			let friendRequest = friendRequests[indexPath.row]
			cell.configure(friendRequest)
			cell.delegate = self
			return cell
			
		case .EventRequests:
			let cell = tableView.dequeueReusableCellWithType(EventInvitationCell.self)
			cell.delegate = self
			cell.configure(invitations[indexPath.row])
			return cell
			
		case .Events:
			let cell = tableView.dequeueReusableCellWithType(EventCell.self)
			let event = events[indexPath.row]
			cell.configure(event)
			return cell
		}
	}
	
	// MARK: - Action -
	
	func createEventSelected(sender: AnyObject) {
		performSegueWithIdentifier("CreateEventViewController", sender: self)
	}
	
	// MARK: - FriendRequestCellCellDelegate -
	
	public func friendRequestCellDidSelectAccept(cell: FriendRequestCell) {
		let indexPath = tableView.indexPathForCell(cell)!
		respondToFriendRequest(indexPath, state: .Accepted)
	}
	
	public func friendRequestCellDidSelectDecline(cell: FriendRequestCell) {
		let indexPath = tableView.indexPathForCell(cell)!
		respondToFriendRequest(indexPath, state: .Declined)
	}
	
	private func respondToFriendRequest(indexPath: NSIndexPath, state: FriendRequest.State) {
		let request = friendRequests[indexPath.row]
		
		friendService.respondToFriendRequest(request, status: state) { [weak self] error in
			
			if error == nil {
				self?.tableView.beginUpdates()
				self?.friendRequests.removeAtIndex(indexPath.row)
				self?.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
				self?.tableView.endUpdates()
			}
		}
	}
	
	// MARK: - EvnetInvitationCellDelegate -
	
	public func eventInvitationCellDidSelectAccept(cell: EventInvitationCell) {
		let indexPath = tableView.indexPathForCell(cell)
		let inviation = invitations[indexPath!.row]
		
		eventService.respondToInvitation(inviation, state: .Accepted) { [weak self] error in
			if error == nil {
				self?.tableView.beginUpdates()
				self?.invitations.removeAtIndex(indexPath!.row)
				self?.events.insert(inviation.event, atIndex: 0)
				self?.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
				self?.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: Section.Events.rawValue)], withRowAnimation: .Automatic)
				self?.tableView.endUpdates()
			}
			else {
				UIAlertController.show(self!, title: "Error", message: "Error responding to invitation")
			}
		}
	}
	
	public func eventInvitationCellDidSelectDecline(cell: EventInvitationCell) {
		let indexPath = tableView.indexPathForCell(cell)
		let inviation = invitations[indexPath!.row]

		eventService.respondToInvitation(inviation, state: .Declined) { [weak self] error in
			if error == nil {
				self?.tableView.beginUpdates()
				self?.invitations.removeAtIndex(indexPath!.row)
				self?.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
				self?.tableView.endUpdates()
			}
			else {
				UIAlertController.show(self!, title: "Error", message: "Error responding to invitation")
			}
		}
	}
	
	public func eventInvitationCellDidExpire(cell: EventInvitationCell) {
		
		if let indexPath = tableView.indexPathForCell(cell) {
			
			let inviation = invitations[indexPath.row]
			
			tableView.beginUpdates()
			invitations.removeAtIndex(indexPath.row)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
			tableView.endUpdates()
		}
	}
	
	// MARK: - CreateEventViewControllerDelegate -
	
	public func createEventViewControllerDidSelectCancel(controller: CreateEventViewController) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	public func createEventViewController(controller: CreateEventViewController, didCreateEvent event: Event) {
		tableView.beginUpdates()
		events.insert(event, atIndex: 0)
		tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: Section.Events.rawValue)], withRowAnimation: .Automatic)
		tableView.endUpdates()
	}
	
	// MARK: - Private -
	
	private func fetchAndPopulateData() {
		var eventsCompleted = false
		var invitationsCompleted = false
		var newEvents = [Event]()
		var newInvitations = [EventInvitation]()
		
		eventService.fetchMyEvents { [weak self] events, error in
			if error == nil {
				events?.each { newEvents.append($0) }
			}
			else {
				// Error
			}
			
			eventsCompleted = true
			
			if eventsCompleted && invitationsCompleted {
				self?.fetchCompletion(newEvents, newInvitations: newInvitations)
			}
		}
		
		eventService.fetchMyInvitations { [weak self] invitations, error in
			if error == nil {
				invitations?.each {
					
					if $0.stateEnum == .Accepted {
						newEvents.append($0.event)
					}
					else if $0.stateEnum == .Pending {
						newInvitations.append($0)
					}
				}
				
				self!.tableView.reloadData()
			}
			else {
				// Error
			}
			
			invitationsCompleted = true
			
			if eventsCompleted && invitationsCompleted {
				self?.fetchCompletion(newEvents, newInvitations: newInvitations)
			}
		}
		
		friendService.fetchPendingFriendRequests() { [weak self] friendRequests, error in
			
			if error == nil {
				self?.friendRequests = friendRequests!
				self?.tableView.reloadData()
			}
			else {
				
			}
		}
	}
	
	private func fetchCompletion(newEvents: [Event]?, newInvitations: [EventInvitation]?) {
		if let newEvents = newEvents {
			events = newEvents
		}
		
		if let newInvitations = newInvitations {
			invitations = newInvitations
		}
		
		tableView.reloadData()
		tableView.pullToRefreshView.stopAnimating()
	}
	
}
