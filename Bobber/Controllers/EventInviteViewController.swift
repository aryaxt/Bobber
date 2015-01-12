//
//  EventInviteViewController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/11/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

class EventInviteViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var contacts = [Contact]()
    var contactsManager = ContactsManager()
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: UIViewController names
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateContactList()
    }

    // MARK: UITableView Delegate & Datasource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "personCell"
        let cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
        cell.textLabel?.text = "\(contacts[indexPath.row].firstName!) \(contacts[indexPath.row].lastName!) \(contacts[indexPath.row].phoneNumber!)"
        
        return cell
    }
    
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
