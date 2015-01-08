
var GOOGLE_AUTOCOMPLETE_API_KEY = "AIzaSyC52xwGjuNVfBq4yHlQiGrlswCERkZZ16w";

var twilio = require("twilio");
twilio.initialize("myAccountSid","myAuthToken");


Parse.Cloud.beforeSave("Event", function(request, response) {

});
 
Parse.Cloud.define("inviteWithTwilio", function(request, response) {
	twilio.sendSMS({
		From: "myTwilioPhoneNumber",
		To: request.params.number,
		Body: "Start using Parse and Twilio!"
	}, {
		success: function(httpResponse) { 
    		requestesponse.success("SMS sent!"); 
    	},
    	error: function(httpResponse) { 
    		response.error("Uh oh, something went wrong"); 
    	}
  	});
});


Parse.Cloud.define("Autocomplete", function(request, response) {
	var input = request.params.query;
	var url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?types=geocode&input=" + input + "&key=" +  GOOGLE_AUTOCOMPLETE_API_KEY;
	url = url.split(" ").join("+");
	console.log(url);

	Parse.Cloud.httpRequest({
	  	method: "GET",
	  	url: url,
	  	success: function(httpResponse) {
	    	response.success(httpResponse.text);
	  	},
		error: function(error) {
			console.error(error);
			response.error("Failed to request autocomplete api ");
		}
	});
});


Parse.Cloud.define("PlaceDetail", function(request, response) {
	var placeId = request.params.placeId;
	var url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=" + placeId + "&key=" +  GOOGLE_AUTOCOMPLETE_API_KEY;
	url = url.split(" ").join("+");
	console.log(url);
	
	Parse.Cloud.httpRequest({
	  	method: "GET",
	  	url: url,
	  	success: function(httpResponse) {
	    	response.success(httpResponse.text);
	  	},
		error: function(error) {
			console.error(error);
			response.error("Failed to request autocomplete api ");
		}
	});
});


Parse.Cloud.define("UserNotificationSetting", function(request, response) {
	Parse.Cloud.useMasterKey();
	var notificationSettingsQuery = new Parse.Query("NotificationSetting");
	
	notificationSettingsQuery.find({
		success: function(notificationSettings) {
			
			var userNotificationSettingsQuery = new Parse.Query("UserNotificationSetting");
			userNotificationSettingsQuery.equalTo("user", Parse.User.current());
			userNotificationSettingsQuery.include("notificationSetting");
			userNotificationSettingsQuery.find({
				success: function(userSettings) {

					var newUserSettings = [];
					
					for (var i=0 ; i<notificationSettings.length ; i++) {
						var notificationSetting = notificationSettings[i];
						var userSettingExists = false;
						
						for (var j=0 ; j<userSettings.length ; j++) {
							var userSetting = userSettings[j];
							if (userSetting.get("notificationSetting").id == notificationSetting.id) {
								newUserSettings.push(userSetting);
								userSettingExists = true;
								break;
							}
						}
						
						if (userSettingExists == false) {
							var UserNotificationSetting = Parse.Object.extend("UserNotificationSetting");
							var userSetting = new UserNotificationSetting();
							userSetting.set("user", Parse.User.current());
							userSetting.set("notificationSetting", notificationSetting);
							userSetting.set("enabled", notificationSetting.get("defaultValue"));
							newUserSettings.push(userSetting);
						}
					}
					
					Parse.Object.saveAll(newUserSettings, {
				    	success: function(list) {
				      		response.success(newUserSettings);
				    	},
				    	error: function(error) {
				      		console.error(error);
					    	response.error("Failed to read notification settings");
				    	}
					});
				},
				error: function(object, error) {
					console.error(error);
			    	response.error("Failed to read notification settings");
				}
			});
		},
		error: function(object, error) {
			console.error(error);
	    	response.error("Failed to read notification settings");
		}
	});
});
