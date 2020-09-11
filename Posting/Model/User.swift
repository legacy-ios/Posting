//
//  User.swift
//  Posting
//
//  Created by jungwooram on 2020-05-19.
//  Copyright © 2020 jungwooram. All rights reserved.
//

import Foundation
import Firebase

class User {
    
    var username: String!
    var name: String!
    var profileImageUrl: String!
    var uid: String!
    var isFollowed = false

    init(uid: String, dictionary: Dictionary<String, AnyObject>) {
        
        self.uid = uid
        
        if let username = dictionary["username"] as? String {
            self.username = username
        }
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
            self.profileImageUrl = profileImageUrl
        }
    }
    
    func follow() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        guard let uid = uid else { return }
        
        self.isFollowed = true
        
        //add followed user to current user-following structure
        USER_FOLLOWING_REF.child(currentUid).updateChildValues([uid: 1])
        
        //add current user to followed user-follower structure
        USER_FOLLOWER_REF.child(uid).updateChildValues([currentUid: 1])
        
        //add followed users posts to current user feed
        USER_POSTS_REF.child(self.uid).observe(.childAdded) { snapshot in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
        }
    }
    
    func unfollow() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        guard let uid = uid else { return }
        
        self.isFollowed = false
        
        //remove user from current user-following structure
        USER_FOLLOWING_REF.child(currentUid).child(uid).removeValue()
        
        //remove user from current user-followed structure
        USER_FOLLOWER_REF.child(uid).child(currentUid).removeValue()
        
        //remove unfollowed users posts from curretn user-feed
        USER_POSTS_REF.child(self.uid).observe(.childAdded) { snapshot in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).child(postId).removeValue()
        }
    }
    
    func checkIfUserIsFollowed(completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        USER_FOLLOWING_REF.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            if snapshot.hasChild(self.uid) {
                self.isFollowed = true
                completion(true)
            } else {
                self.isFollowed = false
                completion(false)
            }
        }
    }
    
    func uploadFollowNotificationServer() {
        
    }
}
