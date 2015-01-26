
var GoogleAutocompleteApiKey = "AIzaSyC52xwGjuNVfBq4yHlQiGrlswCERkZZ16w";

exports.autocomplete = function(query, completion) {
    
    var url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?types=geocode&input=" + query + "&key=" +  GoogleAutocompleteApiKey;
    url = url.split(" ").join("+");

    Parse.Cloud.httpRequest({
        method: "GET",
        url: url,
        success: function(httpResponse) {
            completion(httpResponse.text, null)l
        },
        error: function(error) {
            completion(null, error);
        }
    });
    
}

exports.placeDetail(placeId, completion) {

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