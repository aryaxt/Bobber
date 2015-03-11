
var FriendStatusPending = "pending";
var FriendStatusAccepted = "accepted";
var FriendStatusCanceled = "canceled";

var userNotificationSettingsService = require("cloud/userNotificationSettings.js");
var phoneVerificationService = require("cloud/phoneVerification.js");
var eventService = require("cloud/event.js");
var googleLocationService = require("cloud/googleLocation.js");
var locationService = require("cloud/location.js");


Parse.Cloud.beforeSave(Parse.User, function(request, response) {
    response.success();
});


Parse.Cloud.beforeSave("Comment", function(request, response) {
    // TODO: Only allow confirmed attendees to make comments
    response.success();

});


Parse.Cloud.afterSave("Comment", function(request, response) {
	eventService.sendCommentNotification(Parse.User.current(), request.object, function(error) {
        if (error != null) {
            console.error(error);
        }
    });
});


Parse.Cloud.beforeSave("Event", function(request, response) {
    // TODO: Handle state change and send push notification (canceled, location change, etc)
    // TODO: Make sure only creator can modify event
	// TODO: If time and location are missing set state to 'planning'
                       
    response.success();
});


Parse.Cloud.beforeSave("EventDateSuggestion", function(request, response) {
	// TODO: Check for duplicate
	// TODO: Make sure it allows suggestion
	response.success();
});


Parse.Cloud.beforeSave("EventLocationSuggestion", function(request, response) {
	// TODO: Check for duplicate
	// TODO: Make sure it allows suggestion
	response.success();
});


Parse.Cloud.afterSave("Location", function(request, response) {		  
	//locationService.updateLocationIfNeeded(request.object);
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
	if (request.object.isNew()) {
        eventService.sendInvite(Parse.User.current(), request.object, function(error) {
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
        eventService.respondToInvite(Parse.User.current(), request.object, function(error) {
            if (error == null) {
                response.success()
            }
            else {
                console.error(error);
                response.error(error);
            }
        });
	}
});


Parse.Cloud.beforeSave("PhoneVerification", function(request, response) {
    if (request.object.isNew()) {
        phoneVerificationService.sendVerification(Parse.User.current(), request.object, function(error) {
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
    phoneVerificationService.verifyPhoneNumber(Parse.User.current(), request.params.phoneNumber, request.params.verificationCode, function(error) {
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
    googleLocationService.autocomplete(request.params.query, function(result, error) {
        if (error == null) {
            response.success(result);
        }
        else {
            console.error(error);
            response.error("Failed to request autocomplete api");
        }
    });
});


Parse.Cloud.define("PlaceSearch", function(request, response) {
    googleLocationService.placeTextSearch(request.params.query, function(result, error) {
        if (error == null) {
            response.success(result);
        }
        else {
            console.error(error);
            response.error("Failed to request place detail api");
        }
    });
});


Parse.Cloud.define("PlaceDetail", function(request, response) {
    googleLocationService.placeDetail(request.params.placeId, function(result, error) {
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
    userNotificationSettingsService.getUserNotificationSettings(user, function(result, error) {
        if (error == null) {
            response.success(result);
        }
        else {
            console.error(error);
            response.error("Failed to get user notitication settings");
        }
    });
});


Parse.Cloud.define("EventSuggestions", function(request, response) {
	// TODO: Add cloud code to return number of suggestion location/dates because we don't want to just send them all to client
});

