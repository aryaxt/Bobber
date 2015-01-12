
var twilio = require("twilio")("ACb8e7c20f71bc52e069567bb436edeb30", "03d2d4e99036f661c9fd5ed74b5de9a8");
var GoogleAutocompleteApiKey = "AIzaSyC52xwGjuNVfBq4yHlQiGrlswCERkZZ16w";
var TwilloPhoneVerificationNumber = "+18587719306";
var EventStatusPending = "pending";
var EventStatusActive = "active";
var EventStatusCanceled = "canceled";
var EventAttendeeStatusPending = "pending";
var EventAttendeeStatusAccepted = "accepted";
var EventAttendeeStatusCanceled = "canceled";
var FriendStatusPending = "pending";
var FriendStatusAccepted = "accepted";
var FriendStatusCanceled = "canceled";


Parse.Cloud.beforeSave(Parse.User, function(request, response) {
    response.success();
});


Parse.Cloud.beforeSave("FriendRequest", function(request, response) {
    // TODO: Handle state change and send push notification
    // TODO: Make sure only creator can modify event
                       
    response.success();
});


Parse.Cloud.beforeSave("FriendRequest", function(request, response) {
	// TODO: Make sure a duplicate doesn't exist when isNew
	// TODO: If it's new set status to pending   
	// TODO: If it's not new make sure user are not changing
	// TODO: If it's not new make sure status is valid
    // TODO: Make sure only "to" user can update

    response.success();
});


Parse.Cloud.beforeSave("EventInvitation", function(request, response) {
    // TODO: If phoneNumber MD5 passed check for existing user before sending sms
    // TODO: Create Friend invitation id doesn't exist
    // TODO: Check for duplicate and error out
    // TODO: Send push notification when needed
    // TODO: Send SMS invitation when needed
    // TODO: Check for blocked user
    // TODO: Increment event.inviteeCount
    // TODO: Make sure we haven't reached maxNumber
    // TODO: If we have reached minNumber make active and send text
                    
    response.success();
});


Parse.Cloud.beforeSave("PhoneVerification", function(request, response) {
    // TODO: Make sure user doesn't send too many
    if (!request.object.isNew()) {
        response.success();
        return;               
    }
                       
    var md5 = require("cloud/md5.js");
    var verificationCode = Math.floor(Math.random() * 9999) + 1000
    var phoneNumber = request.object.get("phoneNumber")
     
    twilio.sendSms({
        	from: TwilloPhoneVerificationNumber,
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
                   
                request.object.set("verificationCode", verificationCode);
                request.object.set("phoneNumber", md5.hex_md5(phoneNumber));
                response.success();
            }
    });
    
});


Parse.Cloud.define("VerifyPhoneNumber", function(request, response) {
    // TODO: after verified set user.phoneNumber
    // TODO: Make sur pone number is not in use already
    // TODO: limit number of attempts
    // TODO: Assing user to friend invitations (bsed on phoneNumber)
    // TODO: Assing user to event invitations (bsed on phoneNumber)
    
    // Users don't have read permission to this table, need to use master key
    Parse.Cloud.useMasterKey();
                   
    var md5 = require("cloud/md5.js");
    var verificationCode = request.params.verificationCode;
    var phoneNumberHashed = md5.hex_md5(request.params.phoneNumber)
               
    // Find last PhoneVerification for a given user and phone number
    var query = new Parse.Query("PhoneVerification");
    query.equalTo("user", Parse.User.current());
    query.equalTo("phoneNumber", phoneNumberHashed);
    query.descending("createdAt");
    query.limit(1);

    query.find({
        success: function(results) {
            var phoneNumberVerification = results[0];
               
            // If provided verification code is correct
            if (phoneNumberVerification.get("verificationCode") == verificationCode) {
                phoneNumberVerification.set("verificationResult", true);
                phoneNumberVerification.save().then(function(verification){

                	// Also save phone number on user object
					Parse.User.current().set("phoneNumber", phoneNumberHashed);
					Parse.User.current().save();
					response.success();
                });
            }
            else {
                phoneNumberVerification.set("verificationResult", false);
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


Parse.Cloud.define("Autocomplete", function(request, response) {
	var input = request.params.query;
	var url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?types=geocode&input=" + input + "&key=" +  GoogleAutocompleteApiKey;
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
	var url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=" + placeId + "&key=" +  GoogleAutocompleteApiKey;
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
