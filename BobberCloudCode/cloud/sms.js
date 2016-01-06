
var twilio = require("twilio")("", "");
var TwilloPhoneVerificationNumber = "+18587719306";

exports.sendSms = function(phoneNumber, message, completion) {
    
    twilio.sendSms({
        	from: TwilloPhoneVerificationNumber,
        	to: phoneNumber,
        	body: message
   		},
        function(error, httpResponse) {
            if (error) {
                completion(error);
            }
            else {
                completion(null);
            }
    });
}
