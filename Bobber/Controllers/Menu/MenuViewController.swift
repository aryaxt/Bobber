//
//  MenuViewController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 3/11/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

class MenuViewController: UIViewController {
	
	@IBOutlet var tableView: UITableView!
	
	// MARK: - UITableView Delegate & Datasource -
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell") as! UITableViewCell
		
		switch indexPath.row {
		case 0:
			cell.textLabel?.text = "Profile"
		case 1:
			cell.textLabel?.text = "Home"
		case 2:
			cell.textLabel?.text = "Sign Out"
		default :
			break
		}
		
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		switch indexPath.row {
		case 0:
			break
		case 1:
			break
		case 2:
			UIApplication.sharedApplication().cancelAllLocalNotifications()
			PFUser.logOut()
			
			let login = LoginViewController.instantiateFromStoryboard()
			BobberNavigationController.sharedInstance().popAllAndSwitchToViewController(login) {  }
		default :
			break
		}
	}
}
