

var EventInvitationFieldId = "id";
var EventInvitationFieldEvent = "event";
var EventInvitationFieldFrom = "from";
var EventInvitationFieldTo = "to";
var EventInvitationFieldToPhoneNumber = "toPhoneNumber";
var EventInvitationFieldStatus = "status";

var EventStatusPending = "pending";
var EventStatusActive = "active";
var EventStatusPlanning = "planning";
var EventStatusCanceled = "canceled";

var EventInvitationStatusPending = "pending";
var EventInvitationStatusAccepted = "accepted";
var EventInvitationStatusCanceled = "canceled";

var EventInvitationErrorStatusChangeNotallowed = "event_invitation_status_change_not_allowed";
var EventInvitationErrorStatusChangeInvalidUser = "event_invitation_status_change_invalid_user";
var EventInvitationErrorStatusInvalid = "event_invitation_status_invalid";


exports.respondToInvite = function (user, invitation, completion) {
    // TODO: Send push notification to users
    // TODO: Add notification setting
    
    var newStatus = invitation.get(EventInvitationFieldStatus);
    var invitationId = invitation.get(EventInvitationFieldId);
    var invitationQuery = new Parse.Query("EventInvitation");
    
    invitationQuery.get(request.object.id, { 
        success: function(oldInvitation) {

   			if (oldInvitation.get(EventInvitationFieldStatus) != EventStatusPending) {
        		completion(EventInvitationErrorStatusChangeNotallowed);
    		}
    		else if (invitation.get(EventInvitationFieldTo).get(EventInvitationFieldId) != user.get(EventInvitationFieldId)) {
        		completion(EventInvitationErrorStatusChangeInvalidUser);
    		}
    		else if (newStatus != EventInvitationStatusAccepted && newStatus != EventInvitationStatusCanceled) {
    			completion(EventInvitationErrorStatusInvalid);
    		}
    		else {
        		completion(null);
    		}
        },
        error: function(row, error) {
            completion(error);
        }
    });
}

exports.sendInvite = function(invitation, completion) {
    
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

	var push = require("cloud/push.js");
	var sms = require("cloud/sms.js");
	var md5 = require("cloud/md5.js");
	var phoneNumber = invitation.get(EventInvitationFieldToPhoneNumber).replace(/\D/g,"");
	var phoneNumberHashed = md5.hex_md5(phoneNumber);
    
    invitation.set(EventInvitationFieldStatus, EventInvitationStatusPending);

	// If attempting to invite a user with phone number
	if (phoneNumber != null) {

	    var userQuery = new Parse.Query(Parse.User);
	    userQuery.equalTo(EventInvitationFieldToPhoneNumber, phoneNumberHashed);
	    userQuery.find({success: function(users) {
	            
	            // User doesn't exist send sms
	            if (users.length == 0) {
	                sms.sendSms(phoneNumber, "Hello dude", function(error) {
	                    if (error == null) {
	                        completion(null);
	                    }
	                    else {
	                        completion(error);
	                    }
	                });
	            }
	            // User with phone number exists send a push
	            else {
	                // TODO: Try reusing this code

	                var user = users[0];

	                // User is already here remove phone set user to invitation
	                invitation.set(EventInvitationFieldTo, user);
	                invitation.set(EventInvitationFieldToPhoneNumber, null);

	                var pushData = { "alert": "Hello dude" };
	                var installationQuery = new Parse.Query("Installation");
	                installationQuery.equalTo("user", user);

	                push.sendPushNotification(installationQuery, pushData, function(error) {
	                    if (error == null) {
	                        completion(null);
	                    }
	                    else {
	                        completion(error);
	                    }
	                });
	            }
	        },
	        error: function(error) {
	            completion(error);
	        }
	    });
	}
	// If attempting to invite an existing user
	else if (invitation.get("to") != null) {
	            
	    var pushData = { "alert": "Hello dude" };
	    var user = invitation.get(EventInvitationFieldTo);
	    var installationQuery = new Parse.Query("Installation");
	    installationQuery.equalTo("user", user);

	    push.sendPushNotification(installationQuery, pushData, function(error) {
	        if (error == null) {
	            completion(null);
	        }
	        else {
	            completion(error);
	        }
	    });
	}
	// No existing user and no phone number
	else {
		completion("No user or phone provided");
	}
    
}
