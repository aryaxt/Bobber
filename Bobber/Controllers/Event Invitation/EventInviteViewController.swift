//
//  EventInviteViewController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/11/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class EventInviteViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var event: Event!
    var contacts = [Contact]()
    var friends = [User]()
    lazy var contactsManager = ContactsManager()
    lazy var eventService = EventService()
    lazy var friendService = FriendService()
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - UIViewController names -
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        populateContactList()
        
        friendService.fetchFriends { friends, error in
            if error == nil {
                self.friends = friends!
            }
            else {
                UIAlertController.show(self, title: "Error", message: "Error getting your friends")
            }
            
            self.tableView.reloadData()
        }
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EventInviteViewController" {
            var destination = segue.destinationViewController as! EventInviteViewController
            destination.event = event
        }
    }

    // MARK: - UITableView Delegate & Datasource -
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return friends.count
        }
        else {
            return contacts.count
        }
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        if indexPath.section == 0 {
            let identifier = "FriendCell"
            cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
            cell.textLabel?.text = "\(friends[indexPath.row].firstName) \(friends[indexPath.row].lastName)"
        }
        else {
            let identifier = "PersonCell"
            cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
            cell.textLabel?.text = "\(contacts[indexPath.row].firstName) \(contacts[indexPath.row].lastName) \(contacts[indexPath.row].phoneNumber!)"
        }
        
        return cell
    }

	public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = RoundedHeaderView.instantiateFromNib()
		header.setTitle(section == 0 ? "Bobber Friends" : "Contacts")
		return header
	}
	
	public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return RoundedHeaderView.height()
	}
	
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		if indexPath.section == 0 {
			eventService.invite(event, user: friends[indexPath.row]) { error in
				
			}
		}
		else {
			eventService.invite(event, toPhoneNumber: contacts[indexPath.row].phoneNumber!) { error in
				
			}
		}
    }
	
    // MARK: - Actions -
    
    @IBAction func cancelSelected(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Private -
    
    private func populateContactList() {
        contactsManager.fetchContactsWithMobileNumber { contacts, error in
            
            if let anError = error {
                // Handle error
                self.contacts = [Contact]()
            }
            else {
                self.contacts = contacts!
            }
        }
    }
}
