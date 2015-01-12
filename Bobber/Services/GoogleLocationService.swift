//
//  GoogleAutocompleteService.swift
//  Explore
//
//  Created by Aryan on 10/12/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

import Foundation

public class GoogleLocationService {
    
    public func fetchLocations(query: String, block: ([GoogleAutocompleteLocation]?, NSError?) -> Void) {
        
        PFCloud.callFunctionInBackground("Autocomplete", withParameters: ["query" : query]) { (result, error) in
            if let recievedError = error {
                block(nil, error)
            }
            else {
                var autocompleteResult = [GoogleAutocompleteLocation]()
                var data = result.dataUsingEncoding(NSUTF8StringEncoding)!
                var error: NSError?;
                var dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers , error: &error) as NSDictionary
                
                if let predictions = dictionary["predictions"] as? [NSDictionary] {
                    
                    for prediction in predictions {
                        var autoComplere = GoogleAutocompleteLocation(name: prediction["description"] as String, placeId: prediction["place_id"] as String)
                        autocompleteResult.append(autoComplere)
                    }
                }
                
                block(autocompleteResult, nil)
            }
        }
    }
    
    public func fetchLocation (placeId: String, block: (GooglePlaceDetail?, NSError?) -> Void) {
        
        PFCloud.callFunctionInBackground("PlaceDetail", withParameters: ["placeId" : placeId]) { (result, error) in
            if let recievedError = error {
                block(nil, error)
            }
            else {
                var data = result.dataUsingEncoding(NSUTF8StringEncoding)!
                var error: NSError?;
                var dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers , error: &error) as NSDictionary
                
                var location = GooglePlaceDetail()
                location.placeId = dictionary.objectForKeyPath("result.place_id") as? String
                location.formattedAddress = dictionary.objectForKeyPath("result.formatted_address") as? String
                location.latitude = dictionary.objectForKeyPath("result.geometry.location.lng") as? Double
                location.longitude = dictionary.objectForKeyPath("result.geometry.location.lat") as? Double
                
                var addressComponents = dictionary.objectForKeyPath("result.address_components") as [NSDictionary]
                
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
                
                block(location, nil)
            }
        }
    }
}