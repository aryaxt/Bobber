//
//  HomeViewController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/11/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

class HomeViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    lazy var eventService = EventService()
    var events = [Event]()
    
    // MARK: - UIViewController -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventService.fetchMyEvents { events, error in
            if error == nil {
                self.events = events!
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "personCell"
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as UITableViewCell
        cell.textLabel?.text = events[indexPath.row].title
        
        return cell
    }
    
}
