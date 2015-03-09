//
//  GoogleAutocompleteService.swift
//  Explore
//
//  Created by Aryan on 10/12/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

import Foundation

public class GoogleLocationService {
    
    public func searchLocations(query: String, block: ([GoogleAutocompleteLocation]?, NSError?) -> ()) {
        
        PFCloud.callFunctionInBackground("Autocomplete", withParameters: ["query" : query]) { [weak self] (result, error) in
            if let recievedError = error {
                block(nil, error)
            }
            else {
                var autocompleteResult = [GoogleAutocompleteLocation]()
                var data = result.dataUsingEncoding(NSUTF8StringEncoding)!
                var error: NSError?;
                var dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers , error: &error) as NSDictionary
				
				if let error = self!.validateStatus(dictionary) {
					block(nil, error)
					return
				}
				
                if let predictions = dictionary["predictions"] as? [NSDictionary] {
					
                    for prediction in predictions {
						
						let firstTerms = prediction["terms"] as [NSDictionary]
						
                        var autoComplere = GoogleAutocompleteLocation(
							name: prediction["description"] as String,
							placeId: prediction["place_id"] as String,
							firstTerm: firstTerms[0].objectForKey("value") as String
						)
						
                        autocompleteResult.append(autoComplere)
                    }
                }
                
                block(autocompleteResult, nil)
            }
        }
    }
	
	public func searchPlaces(query: String, block: ([GooglePlaceDetail]?, NSError?) -> ()) {
		
		PFCloud.callFunctionInBackground("PlaceSearch", withParameters: ["query" : query]) { [weak self] (result, error) in
			if let recievedError = error {
				block(nil, error)
			}
			else {
				var data = result.dataUsingEncoding(NSUTF8StringEncoding)!
				var error: NSError?;
				var dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers , error: &error) as NSDictionary

				if let error = self!.validateStatus(dictionary) {
					block(nil, error)
					return
				}
				
				var results = dictionary.objectForKey("results") as [NSDictionary]
				var placeDetails = [GooglePlaceDetail]()
				
				for placeDict in results {
					placeDetails.append(self!.placeDetailFromDictionary(placeDict))
				}
				
				block(placeDetails , nil)
			}
		}
	}
	
    public func fetchPlaceDetail (placeId: String, block: (GooglePlaceDetail?, NSError?) -> ()) {
        
        PFCloud.callFunctionInBackground("PlaceDetail", withParameters: ["placeId" : placeId]) { [weak self] (result, error) in
            if let recievedError = error {
                block(nil, error)
            }
            else {
                var data = result.dataUsingEncoding(NSUTF8StringEncoding)!
                var error: NSError?;
                var dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers , error: &error) as NSDictionary
				
				if let error = self!.validateStatus(dictionary) {
					block(nil, error)
					return
				}
				
                let detail = self!.placeDetailFromDictionary(dictionary)
				
                block(detail, nil)
            }
        }
    }
	
	// MARK: - Private -
	
	
	private func validateStatus(dictionary: NSDictionary) -> NSError? {
		let status = dictionary.objectForKey("status") as String
		
		if status != "OK" && status != "ZERO_RESULTS" {
			return NSError(domain: status, code: 0, userInfo: dictionary)
		}
		
		return nil
	}
	
	private func placeDetailFromDictionary(dictionary: NSDictionary) -> GooglePlaceDetail {
		
		var location = GooglePlaceDetail()
		location.placeId = dictionary.objectForKey("place_id") as? String
		location.name = dictionary.objectForKey("name") as? String
		location.formattedAddress = dictionary.objectForKey("formatted_address") as? String
		location.latitude = dictionary.objectForKey("geometry.location.lng") as? Double
		location.longitude = dictionary.objectForKey("geometry.location.lat") as? Double
		
		if let addressComponents = dictionary.objectForKey("address_components") as? [NSDictionary] {
			
			for component in addressComponents {
				var type = component["types"] as [String]
				var longName = component["long_name"] as String?
				
				if (contains(type, "street_number")) {
					location.streetNumber = longName;
				}
				else if (contains(type, "route")) {
					location.street = longName;
				}
				else if (contains(type, "locality")) {
					location.city = longName;
				}
				else if (contains(type, "administrative_area_level_1")) {
					location.state = longName;
				}
				else if (contains(type, "country")) {
					location.country = longName;
				}
				else if (contains(type, "postal_code")) {
					location.postalCode = longName;
				}
			}
		}

		return location
	}
	
}