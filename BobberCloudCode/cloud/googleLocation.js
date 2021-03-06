
var GoogleAutocompleteApiKey = "";

exports.autocomplete = function(query, completion) {
    
    var url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=" + query + "&key=" +  GoogleAutocompleteApiKey;
    url = url.split(" ").join("+");

    Parse.Cloud.httpRequest({
        method: "GET",
        url: url,
        success: function(httpResponse) {
			completion(httpResponse.text, null);
        },
        error: function(error) {
            completion(null, error);
        }
    });
    
}

exports.placeTextSearch = function(query, completion) {

    var url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=" + query + "&key=" +  GoogleAutocompleteApiKey;
    url = url.split(" ").join("+");

    Parse.Cloud.httpRequest({
        method: "GET",
        url: url,
        success: function(httpResponse) {
            completion(httpResponse.text, null);
        },
        error: function(error) {
            completion(null, error);
        }
    });
}

exports.placeLocationSearch = function(location, radius, completion) {

    var url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=" + location + "&type=" + radius + "&key=" +  GoogleAutocompleteApiKey;
    url = url.split(" ").join("+");

    Parse.Cloud.httpRequest({
        method: "GET",
        url: url,
        success: function(httpResponse) {
            completion(httpResponse.text, null);
        },
        error: function(error) {
            completion(null, error);
        }
    });
}

exports.placeDetail = function(placeId, completion) {

    var url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=" + placeId + "&key=" +  GoogleAutocompleteApiKey;
    url = url.split(" ").join("+");

    Parse.Cloud.httpRequest({
        method: "GET",
        url: url,
        success: function(httpResponse) {
            completion(httpResponse.text, null);
        },
        error: function(error) {
            completion(null, error);
        }
    });
}
