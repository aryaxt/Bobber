//
//  CreateEventViewController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/11/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public protocol CreateEventViewControllerDelegate: class {
	func createEventViewControllerDidSelectCancel(controller: CreateEventViewController)
	func createEventViewController(controller: CreateEventViewController, didCreateEvent event: Event)
}

public class CreateEventViewController: BaseViewController {

	@IBOutlet private weak var questionTextView: UITextView!
	@IBOutlet private weak var expirationDateTextField: UITextField!
	@IBOutlet private var datePicker: UIDatePicker!
    private lazy var eventService = EventService()
	public weak var delegate: CreateEventViewControllerDelegate!

    // MARK: - UIViewController -
	
	public override func viewDidLoad() {
		super.viewDidLoad()

		datePicker.hidden = true
		datePickerDidChangeValue(self)
		questionTextView.becomeFirstResponder()
	}
	
	public override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		// Later add 30 minutes back
		datePicker.minimumDate = NSDate() // .dateByAddingTimeInterval(60*30) // 30 minutes
		datePicker.maximumDate = NSDate().dateByAddingTimeInterval(60*60*24*2) // 48 hours
		datePicker.removeFromSuperview()
		datePicker.hidden = false
		expirationDateTextField.inputView = datePicker
	}
	
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateEventInviteViewController" {
            let destination = segue.destinationViewController as EventInviteViewController
			destination.event = sender as Event
        }
    }

	// MARK: - Actions -
	
    @IBAction func cancelSelected(sender: AnyObject) {
        delegate.createEventViewControllerDidSelectCancel(self)
    }
	
	@IBAction func datePickerDidChangeValue(sender: AnyObject) {
		expirationDateTextField.text = datePicker.date.eventFormattedDate()
	}
	
    @IBAction func createEventSelected(sender: AnyObject) {
		eventService.createEvent(questionTextView.text, expirationDate: datePicker.date) { [weak self] (event, error) in
			if error == nil {
				self?.performSegueWithIdentifier("CreateEventInviteViewController", sender: event)
				self?.delegate.createEventViewController(self!, didCreateEvent: event!)
			}
			else {
				//UIAlertView.show("Error", message: "There was a problem creating bob")
			}
		}
    }

}
