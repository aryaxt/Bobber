//
//  EventViewController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/11/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

class EventViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var commentTextView: UITextView!
	@IBOutlet weak var sendCommentButton: UIButton!
    var event: Event!
    var comments = [Comment]()
    lazy var eventService = EventService()
    
    // MARK: - UIViewController -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateEvent()
        
        eventService.fetchDetail(event.objectId) { event, error in
            if let anError = error {
                // Error
            }
            else {
                self.event = event!
                self.populateEvent()
            }
        }
		
		// TODO: Don't preload, wait till user scrolls down
		// TODO: Add pull to refresh, load more, and comment header that contains number of comments
		eventService.fetchComments(event, page: 1, perPage: 25) { comments, error in
			if error == nil {
				comments?.each { self.comments.append($0) }
				self.tableView.reloadData()
			}
			else {
				UIAlertController.show(self, title: "Error", message: "Error posting comment")
			}
		}
    }
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "EventInviteViewController" {
			let destination = segue.destinationViewController as EventInviteViewController
			destination.event = event
		}
	}
	
    // MARK: - Private -
		
    private func populateEvent() {
        titleLabel.text = event.title
    }
	
	// MARK: - Actions -
	
	@IBAction func sendCommentSelected(sender: AnyObject) {
		eventService.addComment(event, text: commentTextView.text) { comment, error in
			if error == nil {
				self.commentTextView.text = nil
				
				// TODO: Don't reload insert cell and animate
				self.comments.insert(comment!, atIndex: 0)
				self.tableView.reloadData()
			}
			else {
				UIAlertController.show(self, title: "Error", message: "Error posting comment")
			}
		}
	}
	
	// MARK: - UITableView Delegate & Datasource -
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return comments.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as UITableViewCell
		let comment = comments[indexPath.row]
		cell.textLabel?.text = comment.from.firstName
		cell.detailTextLabel?.text = comment.text
		return cell
	}
	
}
