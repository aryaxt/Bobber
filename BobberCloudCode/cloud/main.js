
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
    // TODO: If phoneNumber MD5 passed check for existing user before sending sms
    // TODO: Create Friend invitation id doesn't exist
    // TODO: Check for duplicate and error out
    // TODO: Send push notification when needed
    // TODO: Send SMS invitation when needed
    // TODO: Check for blocked user
    // TODO: Increment event.inviteeCount
    // TODO: Make sure we haven't reached maxNumber
    // TODO: If we have reached minNumber make active and send text
    // TODO: Handle allowInvites flag
    // TODO: Don't allow invite after response time is expired
    // TODO: Send push to confirmed attendees registered for new attendees when someone accepts (send reject to owner only?)
                      
     // Creating new invite
	if (request.object.isNew()) {
                       
        var push = require("cloud/push.js");
        var sms = require("cloud/sms.js");

        // If attempting to invite a user with phone number
		if (request.object.get("toPhoneNumber") != null) {
            var md5 = require("cloud/md5.js");
            var phoneNumber = request.object.get("toPhoneNumber").replace(/\D/g,"");
            var phoneNumberHashed = md5.hex_md5(phoneNumber);
                       
            console.log(phoneNumber);
                       
            var userQuery = new Parse.Query(Parse.User);
            userQuery.equalTo("phoneNumber", phoneNumberHashed);
            userQuery.find({success: function(users) {
                    
                    // User doesn't exist send sms
                    if (users.length == 0) {
                        console.log("========1=======");
                        sms.sendSms(phoneNumber, "Hello dude", function(error) {
                            if (error == null) {
                                response.success();
                            }
                            else {
                                console.error(error)
                                response.error(error);
                            }
                        });
                    }
                    // User with phone number exists send a push
                    else {
                        // TODO: Try reusing this code

                        var user = users[0];

                        // User is already here remove phone set user to invitation
                        request.object.set("to", user);
                        request.object.set("toPhoneNumber", null);

                        console.log("========2=======");
                        var pushData = { "alert": "Hello dude" };
                        var installationQuery = new Parse.Query("Installation");
                        installationQuery.equalTo("user", user);
                           console.log("USERRRRRR: " + users);

                        push.sendPushNotification(installationQuery, pushData, function(error) {
                            if (error == null) {
                                response.success();
                            }
                            else {
                                console.error(error)
                                response.error(error);
                            }
                        });
                    }
                },
                error: function(error) {
                    console.error(error);
                    response.error(error);
                }
            });
		}
        // If attempting to invite an existing user
		else if (request.object.get("to") != null) {
                    
            console.log("========3=======");
            var pushData = { "alert": "Hello dude" };
            var user = request.object.get("to");
            var installationQuery = new Parse.Query("Installation");
            installationQuery.equalTo("user", user);

            push.sendPushNotification(installationQuery, pushData, function(error) {
                if (error == null) {
                    response.success();
                }
                else {
                    console.error(error)
                    response.error(error);
                }
            });
		}
        // No existing user and no phone number
		else {
			console.error("No user or phone provided")
			response.error("No user or phone provided");
		}
	}
	else {
         response.success();
	}
});


Parse.Cloud.beforeSave("PhoneVerification", function(request, response) {
    // TODO: Make sure user doesn't send too many
                       
    // When updating don't send sms(ex: set result of verification or number of attempts)
    if (!request.object.isNew()) {
        response.success();
        return;
    }
                       
    var md5 = require("cloud/md5.js");
    var sms = require("cloud/sms.js");
    var verificationCode = Math.floor(Math.random() * 9999) + 1000
    var phoneNumber = request.object.get("phoneNumber");
    request.object.set("user", Parse.User.current());
     
    sms.sendSms(phoneNumber, "Your Bobber verification code is: " + verificationCode, function(error) {
        if (error) {
            console.error(error);
            response.error(error);
        }
        else {
            request.object.set("verificationCode", verificationCode);
            request.object.set("phoneNumber", md5.hex_md5(phoneNumber));
            response.success();
        }
    });
    
});


Parse.Cloud.define("VerifyPhoneNumber", function(request, response) {
    // TODO: Make sure pone number is not in use already
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
    query.equalTo("user", request.user);
    query.equalTo("phoneNumber", phoneNumberHashed);
    query.descending("createdAt");
    query.limit(1);

    query.find({
        success: function(results) {
            var phoneNumberVerification = results[0];
               phoneNumberVerification.increment("numberOfAttmpts");
               
            // If provided verification code is correct
            if (phoneNumberVerification.get("verificationCode") == verificationCode) {
               
                phoneNumberVerification.set("verificationResult", true);
                phoneNumberVerification.save().then(function(verification) {
                                                    
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
