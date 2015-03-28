

var FriendRequestFieldFrom = "from";
var FriendRequestFieldTo = "to";
var FriendRequestFieldState = "state";

var FriendRequestStatePending = "pending";
var FriendRequestStateAccepted = "accepted";
var FriendRequestStateDeclined = "declined";

exports.sendFriendRequestNotification = function(friendRequest, completion) {
	
	var push = require("cloud/push.js");
	var installationQuery = new Parse.Query("Installation");
	installationQuery.equalTo("user", friendRequest.get(FriendRequestFieldTo));
	
	var pushData = {
		"alert" : "Someone sent you a friend request",
		"type" : "friendRequest",
		"data" : friendRequest
	};
	
	push.sendPushNotification(installationQuery, pushData, function(error) {
		if (error == null) {
			if (completion != null)
				completion(null);
		}
		else {
			 if (completion != null)
				 completion(error);
		}
	});
}

exports.handleFriendRequestAcceptedNotification = function(friendRequest, completion) {
	
	if (friendRequest.get(FriendRequestFieldState) == FriendRequestStateDeclined) {
		completion(null);
		return;
	}

	var push = require("cloud/push.js");
	var installationQuery = new Parse.Query("Installation");
	installationQuery.equalTo("user", friendRequest.get(FriendRequestFieldFrom));
	
	var pushData = {
		"alert" : "Someone accepted your friend request",
		"type" : "friendRequestAccepted",
		"data" : friendRequest
	};
	
	push.sendPushNotification(installationQuery, pushData, function(error) {
		if (error == null) {
			if (completion != null)
				completion(null);
		}
		else {
			 if (completion != null)
				 completion(error);
		}
	});
	
}