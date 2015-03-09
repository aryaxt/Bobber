//
//  AutocompleteLocation.swift
//  Explore
//
//  Created by Aryan on 10/12/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

public class GoogleAutocompleteLocation {

    public var name: String
    public var placeId: String
	public var firstTerm: String

	init(name: String, placeId: String, firstTerm: String) {
        self.name = name
        self.placeId = placeId
		self.firstTerm = firstTerm
    }
}
