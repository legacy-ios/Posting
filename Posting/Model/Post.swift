//
//  Post.swift
//  Posting
//
//  Created by jungwooram on 2020-06-02.
//  Copyright © 2020 jungwooram. All rights reserved.
//
import Foundation
import Firebase

class Post {
    
    var caption: String!
    var likes: Int!
    var imageUrl: String!
    var ownerUid: String!
    var creationDate: Date!
    var postId: String!
    var user: User?
    var didlike = false
    
    init(postId: String!, user: User, dictionary: Dictionary<String, AnyObject>) {
        
        self.postId = postId
        
        self.user = user
        
        if let caption = dictionary["caption"] as? String {
            self.caption = caption
        }
        
        if let likes = dictionary["likes"] as? Int {
            self.likes = likes
        }
        
        if let imageUrl = dictionary["imageUrl"] as? String {
            self.imageUrl = imageUrl
        }
        
        if let ownerUid = dictionary["ownerUid"] as? String {
            self.ownerUid = ownerUid
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
    
    func adjustLikes(addLike: Bool, completion: @escaping(Int) -> Void) {

        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let postId = self.postId else { return }
        if addLike {
            
            //send notification to server
            sendLikeNotificationToServer()
            
            //update user-likes structure
            USER_LIKES_REF.child(currentUid).updateChildValues([postId: 1]) { err, ref in
                
                //update post-likes structure
                POST_LIKES_REF.child(self.postId).updateChildValues([currentUid: 1]) { err, ref in
                    self.likes = self.likes + 1
                    self.didlike = true
                    POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
                    completion(self.likes)
                }
            }
            
        } else {

            USER_LIKES_REF.child(currentUid).child(postId).observeSingleEvent(of: .value) { snapshot in
                
                //notification id to remove from server
                guard let notificationID = snapshot.value as? String else { return }
                
                //remove notification from server
                NOTIFICATIONS_REF.child(self.ownerUid).child(notificationID).removeValue { (err, ref) in
                    
                    //remove like from user-likes structure
                    USER_LIKES_REF.child(currentUid).child(postId).removeValue { err, ref in
                        
                        //remove like from post-likes structure
                        POST_LIKES_REF.child(self.postId).child(currentUid).removeValue { err, ref in
                            guard self.likes > 0 else { return }
                            self.likes = self.likes - 1
                            self.didlike = false
                            POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
                            completion(self.likes)
                        }
                    }
                }
            }
        }
    }
    
    func sendLikeNotificationToServer() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let postId = self.postId else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        //only send notification if like is for post that is not current users
        if currentUid != ownerUid {
            
            //notification values
            let values = ["checked": 0,
                          "creationDate": creationDate,
                          "uid": currentUid,
                          "type": LIKE_INT_VALUE,
                          "postId": postId] as [String: Any]
            // notification database reference
            let notificationRef = NOTIFICATIONS_REF.child(ownerUid).childByAutoId()
            
            //upload notification values to database
            notificationRef.updateChildValues(values) { err, ref in
                USER_LIKES_REF.child(currentUid).child(postId).setValue(notificationRef.key)
            }
        }
    }
}
