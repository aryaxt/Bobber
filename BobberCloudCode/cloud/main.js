
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


Parse.Cloud.beforeSave("Comment", function(request, response) {
    // TODO: Only allow confirmed attendees to make comments
    // TODO: Send push to confirmed attendees who are registered for this notification
                       
    response.success();
});


Parse.Cloud.beforeSave("Event", function(request, response) {
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
                      
     // Creating new invite
	if (request.object.isNew()) {
        var event = require("cloud/event.js");

        event.sendInvite(request.object, function(error) {
            if (error == null) {
                response.success()
            }
            else {
                console.error(error);
                response.error(error);
            }
        });
	}
	else {
         response.success();
	}
});


Parse.Cloud.beforeSave("PhoneVerification", function(request, response) {
                       
    // When updating don't send sms(ex: set result of verification or number of attempts)
    if (request.object.isNew()) {
        var phoneVerification = require("cloud/phoneVerification.js");
        phoneVerification.sendVerification(Parse.User.current(), request.object, function(error) {
            if (error) {
                console.error(error);
                response.error(error);
            }
            else {
                response.success();
            }
        });
    }
    else {
        response.success();
    }
});


Parse.Cloud.define("VerifyPhoneNumber", function(request, response) {
    var phoneVerification = require("cloud/phoneVerification.js");

    phoneVerification.verifyPhoneNumber(Parse.User.current(), request.params.phoneNumber, request.params.verificationCode, function(error) {
        if (error == null) {
            response.success();
        }
        else {
            console.error(error);
            response.error(error);
        }
    });             
});


Parse.Cloud.define("Autocomplete", function(request, response) {
    var googleLocation = require("cloud/googleLocation.js");
    
    googleLocation.autocomplete(request.params.query, function(result, error) {
        if (error == null) {
            response.success(result);
        }
        else {
            console.error(error);
            response.error("Failed to request autocomplete api");
        }
    });
});


Parse.Cloud.define("PlaceDetail", function(request, response) {
    var googleLocation = require("cloud/googleLocation.js");
                  
    googleLocation.placeDetail(request.params.placeId, function(result, error) {
        if (error == null) {
            response.success(result);
        }
        else {
            console.error(error);
            response.error("Failed to request place detail api");
        }
    });
});


Parse.Cloud.define("UserNotificationSetting", function(request, response) {
    var userNotificationSettings = require("cloud/userNotificationSettings.js");
    
    userNotificationSettings.getUserNotificationSettings(user, function(result, error) {
        if (error == null) {
            response.success(result);
        }
        else {
            console.error(error);
            response.error("Failed to get user notitication settings");
        }
    });
});
