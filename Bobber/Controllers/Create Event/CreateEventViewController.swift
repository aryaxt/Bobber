//
//  CreateEventViewController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/11/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

class CreateEventViewController: UIViewController, LocationSearchViewControllerDelegate {
    
    lazy var eventService = EventService()
    var event = Event()
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtMinutesToRespond: UITextField!
    @IBOutlet weak var dpDate: UIDatePicker!

    // MARK: - UIViewController -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateEventInviteViewController" {
            let destination = segue.destinationViewController as EventInviteViewController
            destination.event = event
        }
		else if segue.identifier == "LocationSearchViewController" {
			let navigationController = segue.destinationViewController as UINavigationController
			let destination = navigationController.topViewController as LocationSearchViewController
			destination.delegate = self
		}
    }
    
    // MARK: - Actions -
    
    @IBAction func cancelSelected(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func createEventSelected(sender: AnyObject) {
        event.creator = User.currentUser()
        event.title = txtTitle.text
        event.startTime = dpDate.date
        event.minutesToRespond = NSNumber(integer: txtMinutesToRespond.text.toInt()!)
        
        eventService.createEvent(event) { error in
            if error == nil {
                self.performSegueWithIdentifier("EventInviteViewController", sender: self)
            }
            else {
                UIAlertView.show(self, title: "Error", message: "Error creating event")
            }
        }
    }
	
	// MARK: - LocationSearchViewControllerDelegate -
	
	func locationSearchViewController(controller: LocationSearchViewController, didSelectLocation location: GoogleAutocompleteLocation) {
		dismissViewControllerAnimated(true, completion: nil)
		event.location = Location(location)
	}
	
	func locationSearchViewControllerDidCancel(controller: LocationSearchViewController) {
		dismissViewControllerAnimated(true, completion: nil)
	}
    
}
