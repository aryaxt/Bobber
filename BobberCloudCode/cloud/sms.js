

var twilio = require("twilio")("ACb8e7c20f71bc52e069567bb436edeb30", "03d2d4e99036f661c9fd5ed74b5de9a8");
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