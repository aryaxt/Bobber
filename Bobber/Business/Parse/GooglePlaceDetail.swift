//
//  GooglePlaceDetail.swift
//  Explore
//
//  Created by Aryan on 10/16/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

public class GooglePlaceDetail {
	
    var formattedAddress: String?
    var placeId: String?
	var name: String?
    var streetNumber: String?
    var street: String?
    var city: String?
    var country: String?
    var state: String?
    var postalCode: String?
    var latitude: Double?
    var longitude: Double?
	var icon: String?
    
    init() {
        
    }
    
    func fullStreet() -> String {
        var string = ""
        
        if let number = streetNumber {
            string += "\(number) "
        }
        
        if let name = street {
            string += name
        }
        
        return string
    }
}