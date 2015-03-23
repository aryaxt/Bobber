//
//  HomeViewController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/11/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class HomeViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, EventInvitationCellDelegate, SlideNavigationControllerDelegate {
    
    @IBOutlet private weak var tableView: UITableView!
    private lazy var eventService = EventService()
    private var events = [Event]()
	private var invitations = [EventInvitation]()
    
    // MARK: - UIViewController -
    
    override public func viewDidLoad() {
        super.viewDidLoad()
		
		addBarButtonWithTitle("Create", position: .Right, selector: "createEventSelected:")

		fetchAndPopulateData()
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
            var destination = segue.destinationViewController as EventViewController
            let event = events[tableView.indexPathForSelectedRow()!.row]
            destination.event = event
        }
    }
	
	// MARK: - SlideNavigationControllerDelegate -
	
	public func slideNavigationControllerShouldDisplayLeftMenu() -> Bool {
		return true
	}
	
    // MARK: - UITableView Delegate & Datasource -
	
	public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return invitations.count
		}
		else {
			return events.count
		}
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		return cellForRowAtIndexPath(indexPath)
    }
	
	public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = RoundedHeaderView.instantiateFromNib()
		header.setTitle(section == 0 ? "Pending Requests" : "Your Events")
		return header
	}
	
	public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 100
	}
	
	public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return RoundedHeaderView.height()
	}
	
	// MARK: - Private -
	
	public func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCellWithType(EventInvitationCell.self)
			cell.delegate = self
			cell.configure(invitations[indexPath.row])
			return cell
		}
		else {
			let cell = tableView.dequeueReusableCellWithType(EventCell.self)
			let event = events[indexPath.row]
			cell.textLabel?.text = event.title
			cell.detailTextLabel?.text = "\(event.state) \(event.expirationDate)"
			return cell
		}
	}
	
	// MARK: - Action -
	
	func createEventSelected(sender: AnyObject) {
		performSegueWithIdentifier("CreateEventViewController", sender: self)
	}
	
	// MARK: - EvnetInvitationCellDelegate -
	
	public func eventInvitationCellDidSelectAccept(cell: EventInvitationCell) {
		let indexPath = tableView.indexPathForCell(cell)
		let inviation = invitations[indexPath!.row]
		
		eventService.respondToInvitation(inviation, status: .Accepted) { [weak self] error in
			if error == nil {
				self?.tableView.beginUpdates()
				self?.invitations.removeAtIndex(indexPath!.row)
				self?.events.insert(inviation.event, atIndex: 0)
				self?.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
				self?.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: .Automatic)
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

		eventService.respondToInvitation(inviation, status: .Declined) { [weak self] error in
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
					
					if $0.statusEnum == .Accepted {
						newEvents.append($0.event)
					}
					else if $0.statusEnum == .Pending {
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
