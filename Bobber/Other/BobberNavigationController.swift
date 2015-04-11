//
//  BobberNavigationController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/11/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class BobberNavigationController: SlideNavigationController {
    
    public override class func sharedInstance() -> BobberNavigationController {
        return super.sharedInstance() as! BobberNavigationController
    }
    
    public func applyLoggedInState() {
        let homeViewController = UIStoryboard.instantiateViewController(HomeViewController.self)
        popAllAndSwitchToViewController(homeViewController, withCompletion: nil)
    }
}
