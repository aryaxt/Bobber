


exports.sendVerification = function(user, verification, completion) {
	// TODO: Make sure user doesn't send too many

    var md5 = require("cloud/md5.js");
    var sms = require("cloud/sms.js");
    var verificationCode = Math.floor(Math.random() * 9999) + 1000
    var phoneNumber = verification.get("phoneNumber").replace(/\D/g,"");
    verification.set("user", user);
     
    sms.sendSms(phoneNumber, "Your Bobber verification code is: " + verificationCode, function(error) {
        if (error) {
            completion(error);
        }
        else {
            verification.set("verificationCode", verificationCode);
            verification.set("phoneNumber", md5.hex_md5(phoneNumber));
            completion(null);
        }
    });
}

exports.verifyPhoneNumber = function(user, phoneNumber, verificationCode, completion) {

    // TODO: Make sure pone number is not in use already
    // TODO: limit number of attempts
    // TODO: Assing user to friend invitations (bsed on phoneNumber)
    // TODO: Assing user to event invitations (bsed on phoneNumber)

    Parse.Cloud.useMasterKey();
                   
    var md5 = require("cloud/md5.js");
    var phoneNumberHashed = md5.hex_md5(phoneNumber.replace(/\D/g,""));
               
    // Find last PhoneVerification for a given user and phone number
    var query = new Parse.Query("PhoneVerification");
    query.equalTo("user", user);
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
					completion(null);
                });
            }
            else {
                phoneNumberVerification.set("verificationResult", false);
                phoneNumberVerification.save();
                completion("invalide_code");
            }
        },
        error: function(error) {
            completion(error);
        }
    });

}