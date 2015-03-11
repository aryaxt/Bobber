//
//  LocationManager.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 3/8/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class LocationManager: NSObject, CLLocationManagerDelegate {
	
	/*
	Make improvements via: http://nshipster.com/core-location-in-ios-8/
	*/
	
	private var clLocationManager: CLLocationManager!
	public var lastLocation: CLLocation?
	
	// MARK: - Initialization -
	
	class var sharedInstance: LocationManager {
		struct Static {
			static let instance = LocationManager()
		}
		
		return Static.instance
	}
	
	override init() {
		super.init()
		
		clLocationManager = CLLocationManager()
		clLocationManager.delegate = self
		clLocationManager.distanceFilter = kCLDistanceFilterNone
		clLocationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
		
		NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: nil) { note in
			self.clLocationManager.stopUpdatingLocation()
		}
		
		NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) { note in
			if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
				self.startLocationManager()
			}
		}
	}
	
	// MARK: - Public -
	
	public func startLocationManager() {
		
		if self.clLocationManager.respondsToSelector("requestWhenInUseAuthorization") {
			self.clLocationManager.requestWhenInUseAuthorization()
		}
		
		self.clLocationManager.startUpdatingLocation()
	}
	
	
	// MARK: - CLLocationManagerDelegate -
	
	public func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		
	}
	
	public func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
		lastLocation = locations.last as? CLLocation
	}
	
	public func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
		println(error)
	}
}
