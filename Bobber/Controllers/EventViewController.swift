//
//  EventViewController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/11/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

class EventViewController: BaseViewController {
    
    var event: Event!
    var comments: [Comment]!
    lazy var eventService = EventService()
    
    // MARK: - UIViewController -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateEvent()
        
        eventService.fetchEventDetail(event.objectId) { event, error in
            if let anError = error {
                // Error
            }
            else {
                self.event = event!
                self.populateEvent()
            }
        }
    }
    
    // MARK: - Private -
    
    private func populateEvent() {
        self.title = event.title
    }
    
}
