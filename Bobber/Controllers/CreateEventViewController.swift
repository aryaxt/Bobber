//
//  CreateEventViewController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/11/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

class CreateEventViewController: UIViewController {
    
    lazy var eventService = EventService()
    var event: Event!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtMinAttendees: UITextField!
    @IBOutlet weak var txtMaxAttendees: UITextField!
    @IBOutlet weak var txtDetail: UITextView!
    @IBOutlet weak var swtAllowInvites: UISwitch!
    @IBOutlet weak var dpDate: UIDatePicker!

    // MARK: - UIViewController -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EventInviteViewController" {
            var destination = segue.destinationViewController as EventInviteViewController
            destination.event = event
        }
    }
    
    // MARK: - Actions -
    
    @IBAction func cancelSelected(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func createEventSelected(sender: AnyObject) {
        event = Event()
        event.creator = User.currentUser()
        event.title = txtTitle.text
        event.detail = txtDetail.text?
        event.minAttendees = NSNumber(integer: txtMinAttendees.text.toInt()!)
        event.maxAttendees = NSNumber(integer: txtMaxAttendees.text.toInt()!)
        event.detail = txtDetail.text
        event.allowInvites = NSNumber(bool: swtAllowInvites.on)
        event.startTime = dpDate.date
        
        eventService.createEvent(event) { error in
            if error == nil {
                self.performSegueWithIdentifier("EventInviteViewController", sender: self)
            }
            else {
                // Handle error
            }
        }
    }
    
}
