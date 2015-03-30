

// Each notification sent to the client has a "type", the client decides what to do based on the type
var EventCommentNotificationType = "eventComment";
var EventInviteNotificationType = "eventInvite";
var EventExpiredNotificationType = "eventExpired";
var EventFinalConfirmationRequestNotificationType = "finalConfirmation";

var EventNotificationCategoryRespond = "respond";
var EventNotificationCategoryConfirm = "confirm";

var EventFieldCreator = "creator";
var EventFieldTitle = "title";
var EventFieldExpirationDate = "expirationDate";
var EventFieldState = "state";

var EventInvitationFieldId = "id";
var EventInvitationFieldEvent = "event";
var EventInvitationFieldFrom = "from";
var EventInvitationFieldTo = "to";
var EventInvitationFieldToPhoneNumber = "toPhoneNumber";
var EventInvitationFieldState = "state";

var EventCommentFieldFrom = "from";
var EventCommentFieldEvent = "event";
var EventCommentFieldText = "text";
var EventCommentFieldIsSystem = "isSystem";

var EventStateInitial = "initial";
var EventStateCanceled = "canceled";
var EventStateFinalConfirmation = "finalConfirmation";

var EventInvitationStatePending = "pending";
var EventInvitationStateAccepted = "accepted";
var EventInvitationStateCanceled = "canceled";
var EventInvitationStateConfirmed = "confirmed";

var EventInvitationErrorStateChangeNotallowed = "event_invitation_state_change_not_allowed";
var EventInvitationErrorStateChangeInvalidUser = "event_invitation_state_change_invalid_user";
var EventInvitationErrorStateInvalid = "event_invitation_state_invalid";
var EventInvitationErrorMissingUserOrPhone = "event_invitation_missing_user_or_phone";

exports.respondToInvite = function (user, invitation, completion) {
    // TODO: Send push notification to users
    // TODO: Add notification setting
    // TODO: Check to make sure expiration date has not passed
	// If accepted or confirmed send notification to all attendees in this gorup
	// if declined send final notification to creator only
    
    var newState = invitation.get(EventInvitationFieldState);
    var invitationId = invitation.get(EventInvitationFieldId);
    var invitationQuery = new Parse.Query("EventInvitation");
    
    invitationQuery.get(invitationId, {
						
        success: function(oldInvitation) {
						
   			if (oldInvitation.get(EventInvitationFieldState) != EventStateInitial) {
        		completion(EventInvitationErrorStateChangeNotallowed);
    		}
    		else if (invitation.get(EventInvitationFieldTo).get(EventInvitationFieldId) != user.get(EventInvitationFieldId)) {
        		completion(EventInvitationErrorStateChangeInvalidUser);
    		}
    		else if (newState != EventInvitationStateAccepted && newState != EventInvitationStateCanceled) {
    			completion(EventInvitationErrorStateInvalid);
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

	
	var event = invitation.get(EventInvitationFieldEvent);
	var push = require("cloud/push.js");
	var sms = require("cloud/sms.js");
	var md5 = require("cloud/md5.js");
	var phoneNumber = invitation.get(EventInvitationFieldToPhoneNumber);
	var inviteMessage = "Someone sent you a bob (Fix with better message)"; // TODO: Show a better message
    
    invitation.set(EventInvitationFieldState, EventInvitationStatePending);

	// If attempting to invite a user with phone number
	if (phoneNumber != null) {

		phoneNumber = phoneNumber.replace(/\D/g,"");
		var phoneNumberHashed = md5.hex_md5(phoneNumber);
		
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
					   "sound": "default",
					   "category": EventNotificationCategoryRespond,
					   "type" : EventInviteNotificationType,
					   "data" : { "id" : event.id }
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
		
		var pushData = {
			"alert" : inviteMessage,
			"sound": "default",
			"category": EventNotificationCategoryRespond,
			"type" : EventInviteNotificationType,
			"data" : { "id" : event.id }
		};
		
		
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

	var pushData = {
		"alert" : comment.get(EventCommentFieldText),
		"sound": "default",
		"type" : EventCommentNotificationType,
		"data" : comment
	};

	sendNotificationToAttendees(user, event, pushData, true, completion);
}

exports.sendFinalConfirmation = function (user, event, completion) {

	var pushData = {
		"alert" : "Bob was planned, time for final confirmation",
		"sound": "default",
		"type" : EventFinalConfirmationRequestNotificationType,
		"data" : event
	};

	sendNotificationToAttendees(user, event, pushData, false, completion);
}

function sendNotificationToAttendees(user, event, pushData, includeCreator, completion) {
	
	// TODO: Fix. expensive call?
	Parse.Object.fetchAll([event], {
		success: function(list) {
			
			event = list[0];
			var inviteeState;
	
			console.log(event.get(EventFieldState) + " = " + EventStateInitial );
			
			if (event.get(EventFieldState) == EventStateInitial) {
				inviteeState = EventInvitationStateAccepted;
			}
			else {
				inviteeState = EventInvitationStateConfirmed;
			}
			
			var push = require("cloud/push.js");
			console.log(event.get(EventFieldState));
			var invitationQuery = new Parse.Query("EventInvitation");
			invitationQuery.equalTo(EventInvitationFieldEvent, event);
			invitationQuery.equalTo(EventInvitationFieldState, inviteeState);
			invitationQuery.notEqualTo(EventInvitationFieldTo, user);
			invitationQuery.exists(EventInvitationFieldTo);
			invitationQuery.include(EventInvitationFieldTo);
			
			invitationQuery.find({success: function(invitations) {
			            
			    	var users = [];

					// Don't add if creator is the current user sending a message?
			    	if (includeCreator)
						users.push(event.get(EventFieldCreator));
							
					for (var i=0 ; i<invitations.length ; i++) {
						var invitation = invitations[i];
						users.push(invitation.get(EventInvitationFieldTo));
					}
								 
					var installationQuery = new Parse.Query("Installation");
					installationQuery.containedIn("user", users);
			  		push.sendPushNotification(installationQuery, pushData, null);

			  		if (completion != null)
			  			completion(null);
			    },
			    error: function(error) {
			    	if (completion != null)
			        	completion(error);
			    }
			});

		},
		error: function(error) {
			if (completion != null)
				completion(error);
		},
	});

}

//exports.handleExpiredEvents = function (completion) {
//	var push = require("cloud/push.js");
//	var now = new Date();
//	var eventQuery = new Parse.Query("Event");
//	eventQuery.equalTo(EventFieldState, EventStateInitial);
//	eventQuery.lessThanOrEqualTo(EventFieldExpirationDate, now);
//
//	eventQuery.find({success: function(events) {
//
//			for (var i=0 ; i<events.length ; i++) {
//				var event = events[i];
//				event.set(EventFieldState, EventStateExpired);
//
//				var pushData = {
//					"alert" : "Your event has expired, time to pick a location and time",
//					"type" : EventExpiredNotificationType,
//					"data" : event
//				};
//
//	    		var installationQuery = new Parse.Query("Installation");
//	    		installationQuery.equalTo("user", event.get(EventFieldCreator));
//	    		push.sendPushNotification(installationQuery, pushData, null);
//			}
//
//			Parse.Object.saveAll(events, {
//				success: function(list) {
//					completion(null);
//				},
//				error: function(error) {
//				    completion(error);
//				}
//			});
//		},
//	    error: function(error) {
//	        completion(error);
//	    }
//	});
//}


