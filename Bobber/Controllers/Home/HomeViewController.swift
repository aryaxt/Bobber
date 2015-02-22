//
//  HomeViewController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/11/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

class HomeViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, EventInvitationCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    lazy var eventService = EventService()
    var events = [Event]()
	var invitations = [EventInvitation]()
    
    // MARK: - UIViewController -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventService.fetchMyEvents { events, error in
            if error == nil {
				events?.each { self.events.append($0) }
                self.tableView.reloadData()
            }
            else {
                // Error
            }
        }
		
		eventService.fetchMyInvitations { invitations, error in
			if error == nil {
				invitations?.each {
					
					if $0.statusEnum == .Accepted {
						self.events.append($0.event)
					}
					else if $0.statusEnum == .Pending {
						self.invitations.append($0)
					}
				}
				
				self.tableView.reloadData()
			}
			else {
				// Error
			}
		}
	}
	
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EventViewController" {
            var destination = segue.destinationViewController as EventViewController
            let event = events[tableView.indexPathForSelectedRow()!.row]
            destination.event = event
        }
    }
    
    // MARK: - UITableView Delegate & Datasource -
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return invitations.count
		}
		else {
			return events.count
		}
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCellWithIdentifier("EventInvitationCell") as EventInvitationCell
			cell.delegate = self
			cell.configure(invitations[indexPath.row])
			return cell
		}
		else {
			let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as UITableViewCell
			cell.textLabel?.text = events[indexPath.row].title
			return cell
		}
    }
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 300
	}
	
	// MARK: - EvnetInvitationCellDelegate -
	
	func eventInvitationCellDidSelectAccept(cell: EventInvitationCell) {
		let indexPath = tableView.indexPathForCell(cell)
		respondToInvitation(invitations[indexPath!.row], status: .Accepted)
	}
	
	func eventInvitationCellDidSelectDecline(cell: EventInvitationCell) {
		let indexPath = tableView.indexPathForCell(cell)
		respondToInvitation(invitations[indexPath!.row], status: .Declined)
	}
	
	func respondToInvitation(eventInvitation: EventInvitation, status: EventInvitation.Status) {
		eventService.respondToInvitation(eventInvitation, status: status) { error in
			if error == nil {
				
			}
			else {
				UIAlertController.show(self, title: "Error", message: "Error responding to invitation")
			}
		}
	}
	
}