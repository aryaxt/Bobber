
var GOOGLE_AUTOCOMPLETE_API_KEY = "AIzaSyC52xwGjuNVfBq4yHlQiGrlswCERkZZ16w";
var TEILIO_PHONE_VERIFICATION_NUMBER = "+18587719306";
var twilio = require("twilio")("ACb8e7c20f71bc52e069567bb436edeb30", "03d2d4e99036f661c9fd5ed74b5de9a8");


//Parse.Cloud.beforeSave(Parse.User, function(request, response) {
//                       
//});


Parse.Cloud.beforeSave("PhoneVerification", function(request, response) {
    // TODO: Make sure user doesn't send too many
    // TODO: Store phone number as md5
                
    var md5 = require("cloud/md5.js");
    var verificationCode = Math.floor(Math.random() * 9999) + 1000
    var phoneNumber = request.object.get("phoneNumber")
     
    twilio.sendSms({
        from: TEILIO_PHONE_VERIFICATION_NUMBER,
        to: phoneNumber,
        body: "Your Bobber verification code is: " + verificationCode
    },
        function(error, httpResponse) {
            if (error) {
                console.error(error);
                response.error(error);
            }
            else {
                var h = md5.hex_md5("foo");
                   
                request.object.set('verificationCode', verificationCode);
                request.object.set('phoneNumber', md5.hex_md5(phoneNumber));
                response.success();
            }
    });
    
});

Parse.Cloud.define("VerifyPhoneNumber", function(request, response) {
    var md5 = require("cloud/md5.js");
    var verificationCode = request.params.verificationCode;
    var phoneNumberHashed = md5.hex_md5(request.params.phoneNumber)
                   
    var lastPhoneVerificationQuery = new Parse.Query("PhoneVerification");
    lastPhoneVerificationQuery.equalTo("user", Parse.User.current());
    lastPhoneVerificationQuery.equalTo("phoneNumber", phoneNumberHashed);
    lastPhoneVerificationQuery.limit(1)
    lastPhoneVerificationQuery.descending("updatedAt");
                   
    lastPhoneVerificationQuery.find({
        success: function(results) {
            var phoneNumberVerification = results[0];
                                    
            if (phoneNumberVerification.get("verificationCode") == verificationCode) {
                phoneNumberVerification.set('verificationResult', true);
                phoneNumberVerification.save();
                response.success();
            }
            else {
                phoneNumberVerification.set('verificationResult', false);
                phoneNumberVerification.save();
                response.error("invalide_code");
            }
        },
        error: function(error) {
            console.error(error);
            response.error(error);
        }
    });
                   
});

                       
Parse.Cloud.define("InviteUser", function(request, response) {
    // if invite is already sent ignore
        
	twilio.sendSMS({
		From: "(858)771-9306",
		To: "(760)429-3445",
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


Parse.Cloud.define("SendPhoneVerificationMessage", function(request, response) {
    // Make sure user doesn't send too many
    // Create PhoneVerrification object, check to see if an exisitng exists for the current user
    // set phone number, and generate code
});


Parse.Cloud.define("VerifyPhoneNumber", function(request, response) {
    // fetch PhoneVerrification object for given user
    // if code passed is the same as the one stored send success and delete object and set phoneNumberVerified to true on user
    // else return error, and incremenet invalidAttepts
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
