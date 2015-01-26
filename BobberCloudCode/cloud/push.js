

exports.sendPushNotification = function(installationQuery, data, completion) {
    
    Parse.Push.send({
        where: installationQuery,
        data: data
    }, {
        success: function() {
        	completion(null);
		},
		error: function(error) {
			completion(error);
		}
	});
}