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
    lazy var contactsManager = ContactsManager()
    lazy var eventService = EventService()
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - UIViewController names -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateContactList()
    }

    // MARK: - UITableView Delegate & Datasource -
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "personCell"
        let cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
        cell.textLabel?.text = "\(contacts[indexPath.row].firstName!) \(contacts[indexPath.row].lastName!) \(contacts[indexPath.row].phoneNumber!)"
        
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
                self.tableView.reloadData()
            }
        }
    }
}
