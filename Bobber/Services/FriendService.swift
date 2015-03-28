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
		friendRequest.statusEnum = .Pending
        
        friendRequest.saveInBackgroundWithBlock { success, error in
            completion(error)
        }
    }
    
    public func fetchFriends(completion: ([User]? , NSError?)->()) {
        let user = User.currentUser()
        let prediate = NSPredicate(format: "state == %@ AND (from == %@ OR to == %@)", FriendRequest.State.Accepted.rawValue, user, user)
        let query = FriendRequest.queryWithPredicate(prediate)
		query.includeKey("from")
		query.includeKey("to")
        
        query.findObjectsInBackgroundWithCompletion(FriendRequest.self) { friendRequests, error in
            if let anError = error {
                completion(nil, error)
            }
            else {
                var friends = friendRequests!.map { ($0.from.objectId! == User.currentUser().objectId!) ? $0.to! : $0.from }
                completion(friends, nil)
            }
        }
    }
    
    public func respondToFriendRequest(friendRequest: FriendRequest, status: FriendRequest.State, completion: (NSError?)->()) {
        friendRequest.statusEnum = status
        
        friendRequest.saveInBackgroundWithBlock { success, error in
            completion(error)
        }
    }
	
	public func fetchPendingFriendRequests(completion: ([FriendRequest]?, NSError?)->()) {
		let query = FriendRequest.query()
		query.whereKey("to", equalTo: User.currentUser())
		query.whereKey("state", equalTo: FriendRequest.State.Pending.rawValue)
		query.includeKey("from")
		query.findObjectsInBackgroundWithCompletion(FriendRequest.self, completion: completion)
	}

}
