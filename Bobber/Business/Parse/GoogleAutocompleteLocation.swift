//
//  AutocompleteLocation.swift
//  Explore
//
//  Created by Aryan on 10/12/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

public class GoogleAutocompleteLocation {

    var name: String
    var placeId: String

    init(name: String, placeId: String) {
        self.name = name
        self.placeId = placeId
    }
}
