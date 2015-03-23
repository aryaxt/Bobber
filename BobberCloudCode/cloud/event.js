

// Each notification sent to the client has a "type", the client decides what to do based on the type
var EventCommentNotificationType = "eventComment";
var EventInviteNotificationType = "eventInvite";
var EventExpiredNotificationType = "eventExpired";

var EventFieldCreator = "creator";
var EventFieldTitle = "title";
var EventFieldExpirationDate = "expirationDate";
var EventFieldState = "state";

var EventInvitationFieldId = "id";
var EventInvitationFieldEvent = "event";
var EventInvitationFieldFrom = "from";
var EventInvitationFieldTo = "to";
var EventInvitationFieldToPhoneNumber = "toPhoneNumber";
var EventInvitationFieldStatus = "status";

var EventCommentFieldFrom = "from";
var EventCommentFieldEvent = "event";
var EventCommentFieldText = "text";
var EventCommentFieldIsSystem = "isSystem";

var EventStatusPlanning = "planning";
var EventStatusCanceled = "canceled";
var EventStatusExpired = "expired";

var EventInvitationStatusPending = "pending";
var EventInvitationStatusAccepted = "accepted";
var EventInvitationStatusCanceled = "canceled";
var EventInvitationStatusConfirmed = "confirmed";

var EventInvitationErrorStatusChangeNotallowed = "event_invitation_status_change_not_allowed";
var EventInvitationErrorStatusChangeInvalidUser = "event_invitation_status_change_invalid_user";
var EventInvitationErrorStatusInvalid = "event_invitation_status_invalid";
var EventInvitationErrorMissingUserOrPhone = "event_invitation_missing_user_or_phone";

exports.respondToInvite = function (user, invitation, completion) {
    // TODO: Send push notification to users
    // TODO: Add notification setting
    // TODO: Check to make sure expiration date has not passed
    
    var newStatus = invitation.get(EventInvitationFieldStatus);
    var invitationId = invitation.get(EventInvitationFieldId);
    var invitationQuery = new Parse.Query("EventInvitation");
    
    invitationQuery.get(invitationId, {
						
        success: function(oldInvitation) {
						
   			if (oldInvitation.get(EventInvitationFieldStatus) != EventStatusPlanning) {
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
        error: function(error) {
						
            completion(error);
        }
    });
}

exports.sendInvite = function(user, invitation, completion) {
	
	// TODO: Don't allow sending invite to self
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
	var inviteMessage = "Someone sent you a bob (Fix with better message)"; // TODO: Show a better message
    
    invitation.set(EventInvitationFieldStatus, EventInvitationStatusPending);

	// If attempting to invite a user with phone number
	if (phoneNumber != null) {

	    var userQuery = new Parse.Query(Parse.User);
	    userQuery.equalTo("phoneNumber", phoneNumberHashed);
	    userQuery.find({success: function(users) {
	            
	            // User doesn't exist send sms
	            if (users.length == 0) {
					invitation.set(EventInvitationFieldToPhoneNumber, phoneNumberHashed);
					   
	                sms.sendSms(phoneNumber, inviteMessage, function(error) {
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

	                var pushData = {
					   "alert" : inviteMessage,
					   "type" : EventInviteNotificationType,
					   "data" : invitation
					   };
					   
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
	            
	    var pushData = { "alert": inviteMessage };
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
		completion(EventInvitationErrorMissingUserOrPhone);
	}
    
}


exports.sendCommentNotification = function (user, comment, completion) {
	
	var event = comment.get(EventCommentFieldEvent);
	var invitationQuery = new Parse.Query("EventInvitation");
	invitationQuery.equalTo(EventInvitationFieldEvent, event);
	invitationQuery.equalTo(EventInvitationFieldStatus, EventInvitationStatusAccepted);
	invitationQuery.notEqualTo(EventInvitationFieldTo, user);
	invitationQuery.exists(EventInvitationFieldTo);
	invitationQuery.include(EventInvitationFieldTo);

	invitationQuery.find({success: function(invitations) {
	            
	    	var users = [];
			users.push(user);
					
			for (var i=0 ; i<invitations.length ; i++) {
				var invitation = invitations[i];
				users.push(invitation.get(EventInvitationFieldTo));
			}

			var push = require("cloud/push.js");
			var pushData = {
				"alert" : comment.get(EventCommentFieldText),
				"type" : EventCommentNotificationType,
				"data" : comment
			};
						 
			var installationQuery = new Parse.Query("Installation");
			installationQuery.containedIn("user", users);
	  		push.sendPushNotification(installationQuery, pushData, null);
	  		completion(null);
	    },
	    error: function(error) {
	        completion(error);
	    }
	});
}

exports.handleExpiredEvents = function (completion) {
	var push = require("cloud/push.js");
	var now = new Date();
	var eventQuery = new Parse.Query("Event");
	eventQuery.equalTo(EventFieldState, EventStatusPlanning);
	eventQuery.lessThanOrEqualTo(EventFieldExpirationDate, now);

	eventQuery.find({success: function(events) {

			for (var i=0 ; i<events.length ; i++) {
				var event = events[i];
				event.set(EventFieldState, EventStatusExpired);

				var pushData = {
					"alert" : "Your event has expired, time to pick a location and time",
					"type" : EventExpiredNotificationType,
					"data" : event
				};

	    		var installationQuery = new Parse.Query("Installation");
	    		installationQuery.equalTo("user", event.get(EventFieldCreator));
	    		push.sendPushNotification(installationQuery, pushData, null);
			}

			Parse.Object.saveAll(events, {
				success: function(list) {
					completion(null);
				},
				error: function(error) {
				    completion(error);
				}
			});
		},
	    error: function(error) {
	        completion(error);
	    }
	});
}


