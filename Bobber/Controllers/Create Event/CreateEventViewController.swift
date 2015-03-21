//
//  CreateEventViewController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/11/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

class CreateEventViewController: BaseViewController {

	@IBOutlet weak var questionTextView: UITextView!
	@IBOutlet weak var expirationDateTextField: UITextField!
	@IBOutlet var datePicker: UIDatePicker!
    lazy var eventService = EventService()

    // MARK: - UIViewController -
	
	override func viewDidLoad() {
		super.viewDidLoad()

		datePicker.hidden = true
		datePickerDidChangeValue(self)
		questionTextView.becomeFirstResponder()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		datePicker.minimumDate = NSDate().dateByAddingTimeInterval(60*30) // 30 minutes
		datePicker.maximumDate = NSDate().dateByAddingTimeInterval(60*60*24*2) // 48 hours
		datePicker.removeFromSuperview()
		datePicker.hidden = false
		expirationDateTextField.inputView = datePicker
	}
	
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateEventInviteViewController" {
            let destination = segue.destinationViewController as EventInviteViewController
			destination.event = sender as Event
        }
    }

	// MARK: - Actions -
	
    @IBAction func cancelSelected(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
	
	@IBAction func datePickerDidChangeValue(sender: AnyObject) {
		expirationDateTextField.text = datePicker.date.eventFormattedDate()
	}
	
    @IBAction func createEventSelected(sender: AnyObject) {
		eventService.createEvent(questionTextView.text, expirationDate: datePicker.date) { [weak self] (event, error) in
			if error == nil {
				self?.performSegueWithIdentifier("CreateEventInviteViewController", sender: event)
			}
			else {
				//UIAlertView.show("Error", message: "There was a problem creating bob")
			}
		}
    }

}
