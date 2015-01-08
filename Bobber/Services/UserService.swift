//
//  UserService.swift
//  Explore
//
//  Created by Aryan on 10/13/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

public class UserService {
    
    public func authenticateWithFacebook(completion: (NSError?) -> Void) {
        let permissionArray = ["public_profile", "email", "user_friends"]
        
        PFFacebookUtils.logInWithPermissions(permissionArray) { (user, error) in
            
            if let loggedInUser = user {
                self.fetchAndStoreFacebookInfo { error in
                    completion(error)
                }
            }
            else {
                completion(error)
            }
        }
    }
    
    public func fetchFriends(completion: (NSDictionary?, NSError?)->()) {
        FBRequestConnection.startForMyFriendsWithCompletionHandler { request, friends, error  in
            
            if let friendsDictionary = friends["data"] as? [NSDictionary] {
                
                for dictionary in friendsDictionary {
                    println(dictionary)
                }
            }
        }
    }
    
    private func fetchAndStoreFacebookInfo (completion: ((NSError?) -> Void)?) {
        let request = FBRequest.requestForMe()
        
        request.startWithCompletionHandler() { (requestConnection, result, error) in
            
            if let userResult = result as? NSDictionary {
                
                var user = User.currentUser()
                user.firstName = userResult["first_name"] as String
                user.lastName = userResult["last_name"] as String
                user.socialId = userResult["id"] as String?
                user.email = userResult["email"] as String?
                
                if let dateString = userResult["birthday"] as? String {
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    user.birthday = dateFormatter.dateFromString(dateString)
                }
                
                switch userResult["gender"] as String {
                case "male":
                    user.gender = 1
                    
                case "female":
                    user.gender = 2
                    
                default:
                    user.gender = 0
                    
                }
                
                var facebookId = userResult["id"] as String
                user.photoUrl = "https://graph.facebook.com/\(facebookId)/picture"
                
                user.saveInBackgroundWithBlock { (success, error) in
                    if let aBlock = completion {
                        aBlock(error)
                    }
                }
            }
        }
    }
    
}
