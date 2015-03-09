//
//  LocationSearchViewController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 2/14/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

protocol LocationSearchViewControllerDelegate: class {
	func locationSearchViewController(controller: LocationSearchViewController, didSelectLocation location: GoogleAutocompleteLocation)
	func locationSearchViewControllerDidCancel(controller: LocationSearchViewController)
}

class LocationSearchViewController: BaseViewController, UISearchBarDelegate {
	
	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	var locations = [GoogleAutocompleteLocation]()
	lazy var searchService = GoogleLocationService()
	weak var delegate: LocationSearchViewControllerDelegate!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		searchBar.removeFromSuperview()
		navigationItem.titleView = searchBar
		
		searchBar.becomeFirstResponder()
	}
	
	// MARK: - UISearchBarDelegate -

	func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
		searchService.searchLocations(searchText) { autoCompleteLocations, error in
			if error != nil {
				UIAlertController.show(self, title: "Error", message: "Error fetching locations")
			}
			else {
				self.locations.removeAll(keepCapacity: false)
				autoCompleteLocations?.each { self.locations.append($0) }
				self.tableView.reloadData()
			}
		}
	}
	
	// MARK: - IBActions -
	
	@IBAction func closeSelected(sender: AnyObject) {
		self.delegate.locationSearchViewControllerDidCancel(self)
	}
	
	// MARK: - UITableView Delegate & Datasource -
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return locations.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell") as UITableViewCell
		cell.textLabel?.text = locations[indexPath.row].name
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		self.delegate.locationSearchViewController(self, didSelectLocation: locations[indexPath.row])
	}
	
}