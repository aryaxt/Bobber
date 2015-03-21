

exports.sendPushNotification = function(installationQuery, data, completion) {
    
    Parse.Push.send({
        where: installationQuery,
        data: data
    }, {
        success: function() {
			if (completion != null) {
				completion(null);
			}
		},
		error: function(error) {
			if (completion != null) {
				completion(error);
			}
		}
	});
}