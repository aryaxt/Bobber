

exports.getUserNotificationSettings = function(user, completion) {

	Parse.Cloud.useMasterKey();
	var notificationSettingsQuery = new Parse.Query("NotificationSetting");
	
	notificationSettingsQuery.find({
		success: function(notificationSettings) {
			
			var userNotificationSettingsQuery = new Parse.Query("UserNotificationSetting");
			userNotificationSettingsQuery.equalTo("user", user);
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
							userSetting.set("user", user);
							userSetting.set("notificationSetting", notificationSetting);
							userSetting.set("enabled", notificationSetting.get("defaultValue"));
							newUserSettings.push(userSetting);
						}
					}
					
					Parse.Object.saveAll(newUserSettings, {
				    	success: function(list) {
				    		completion(newUserSettings, null);
				    	},
				    	error: function(error) {
				      		completion(null, error);
				    	}
					});
				},
				error: function(object, error) {
					completion(null, error);
				}
			});
		},
		error: function(object, error) {
			completion(null, error);
		}
	});

}