//
//  FriendService.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 1/10/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class FriendService {
    
    public func sendFriendRequest(user: User, completion: (NSError?)->()) {
        let friendRequest = FriendRequest()
        friendRequest.from = User.currentUser()
        friendRequest.to = user
        
        friendRequest.saveInBackgroundWithBlock { success, error in
            completion(error)
        }
    }
    
    public func fetchFriends(completion: ([User]? , NSError?)->()) {
        let user = User.currentUser()
        let prediate = NSPredicate(format: "status == %@ AND (from == %@ OR to == %@)", FriendRequest.Status.Accepted.rawValue, user, user)
        let finalQuery = FriendRequest.queryWithPredicate(prediate)
        
        finalQuery.findObjectsInBackgroundWithCompletion(FriendRequest.self) { friendRequests, error in
            if let anError = error {
                completion(nil, error)
            }
            else {
                var friends: [User] = friendRequests!.map { ($0.from.objectId! == User.currentUser().objectId!) ? $0.to! : $0.from }
                completion(friends, nil)
            }
        }
    }
    
    public func respondToFriendRequest(friendRequest: FriendRequest, status: FriendRequest.Status, completion: (NSError?)->()) {
        friendRequest.statusEnum = status
        
        friendRequest.saveInBackgroundWithBlock { success, error in
            completion(error)
        }
    }

}
