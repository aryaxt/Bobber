

var googleLocationService = require("cloud/googleLocation.js");

var LocationFieldGooglePlaceId = "googlePlaceId";
var LocationFieldStreet = "street";
var LocationFieldCity = "city";
var LocationFieldCountry = "country";
var LocationFielPostalCode = "postalCode";
var LocationFielGeoPoint = "googlePlaceId";

exports.updateLocationIfNeeded = function(location) {
	
	// We already have full info, don't try and fetch
	if (location.get("city") != null) {
		return;
	}
	
	var locationQuery = new Parse.Query("Location");
	locationQuery.equalTo("placeId", location.get("placeId"));
	locationQuery.exists("city");
	locationQuery.limit(1);

    locationQuery.find({
        success: function(results) {
            if (results.length == 1) {
            	var existingLocation = results[0];
            	location.set(LocationFieldStreet, existingLocation.get(LocationFieldStreet));
            	location.set(LocationFieldCity, existingLocation.get(LocationFieldCity));
            	location.set(LocationFieldCountry, existingLocation.get(LocationFieldCountry));
				location.set(LocationFielPostalCode, existingLocation.get(LocationFielPostalCode));
				location.set(LocationFielGeoPoint, existingLocation.get(LocationFielGeoPoint));
				location.save();
            }
            else {
				googleLocationService.placeDetail(location.get(LocationFieldGooglePlaceId), function(result, error) {
					if (error == null) {
						var json = JSON.parse(result);
						var status = json["status"];

						if (status == "OK") {
							var result = json["result"];
							var addressComponents = result["addressComponents"];
							
							for (var i=0 ; i<addressComponents.length ; i++) {
								var component = addressComponents[0];
								
							}

						}
						else {
							console.error("Invalid status form google location API: " + status);
						}
						// TODO: read json and apply detail to location
					}
					else {
						console.logError(error);
					}
				});
            }
        },
        error: function(error) {
			console.logError(error);
        }
    });
}