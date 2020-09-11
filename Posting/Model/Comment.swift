//
//  Comment.swift
//  Posting
//
//  Created by jungwooram on 2020-06-04.
//  Copyright © 2020 jungwooram. All rights reserved.
//

import Foundation
import Firebase

class Comment {
    var uid: String!
    var commentText: String!
    var creationDate: Date!
    var user: User?

    init(user: User, dictionary: Dictionary<String, AnyObject>) {
       
        self.user = user
        
        if let uid = dictionary["uid"] as? String {
            self.uid = uid
        }
        
        if let commentText = dictionary["commentText"] as? String {
            self.commentText = commentText
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
}
