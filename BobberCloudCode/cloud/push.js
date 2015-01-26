

exports.sendPushNotification = function(installationQuery, data, completion) {
    
    var installationQuery = new Parse.Query("Installation");
    installationQuery.equalTo("user", user);

    installationQuery.find().then(function(installations) {

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

    });
}