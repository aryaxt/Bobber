//
//  EventInviteViewController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/11/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

class EventInviteViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var event: Event!
    var contacts = [Contact]()
    var friends = [User]()
    lazy var contactsManager = ContactsManager()
    lazy var eventService = EventService()
    lazy var friendService = FriendService()
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - UIViewController names -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateContactList()
        
        friendService.fetchFriends { friends, error in
            if error == nil {
                self.friends = friends!
            }
            else {
                UIAlertView.show(self, title: "Error", message: "Error getting your friends")
            }
            
            self.tableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EventInviteViewController" {
            var destination = segue.destinationViewController as EventInviteViewController
            destination.event = event
        }
    }

    // MARK: - UITableView Delegate & Datasource -
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        if indexPath.section == 0 {
            let identifier = "FriendCell"
            cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
            cell.textLabel?.text = "\(friends[indexPath.row].firstName) \(friends[indexPath.row].lastName)"
        }
        else {
            let identifier = "PersonCell"
            cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
            cell.textLabel?.text = "\(contacts[indexPath.row].firstName!) \(contacts[indexPath.row].lastName!) \(contacts[indexPath.row].phoneNumber!)"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        eventService.invite(event, toPhoneNumber: contacts[indexPath.row].phoneNumber!) { error in
            
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
