//
//  Constants.swift
//  Posting
//
//  Created by jungwooram on 2020-05-18.
//  Copyright © 2020 jungwooram. All rights reserved.
//

import Foundation
import UIKit
import Firebase

let BUTTON_COLOR_DISABLE = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
let BUTTON_COLOR_ENABLE = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)

// MARK: - Root References

let DB_REF = Database.database().reference()
let STORAGE_REF = Storage.storage().reference()

// MARK: - Storage References

let STORAGE_PROFILE_IMAGES_REF = STORAGE_REF.child("profile_images")
let STORAGE_MESSAGE_IMAGES_REF = STORAGE_REF.child("message_images")
let STORAGE_MESSAGE_VIDEO_REF = STORAGE_REF.child("video_messages")
let STORAGE_POST_IMAGES_REF = STORAGE_REF.child("post_images")

// MARK: - Database References

let USER_REF = DB_REF.child("users")

let USER_FOLLOWER_REF = DB_REF.child("user-followers")
let USER_FOLLOWING_REF = DB_REF.child("user-following")

let POSTS_REF = DB_REF.child("posts")
let USER_POSTS_REF = DB_REF.child("user-posts")

let USER_FEED_REF = DB_REF.child("user-feed")

let USER_LIKES_REF = DB_REF.child("user-likes")
let POST_LIKES_REF = DB_REF.child("post-likes")

let COMMENT_REF = DB_REF.child("comments")

let NOTIFICATIONS_REF = DB_REF.child("notifications")

let MESSAGES_REF = DB_REF.child("messages")
let USER_MESSAGES_REF = DB_REF.child("user-messages")
let USER_MESSAGE_NOTIFICATIONS_REF = DB_REF.child("user-message-notifications")

let HASHTAG_POST_REF = DB_REF.child("hashtag-post")

// MARK: - Decoding Values

let LIKE_INT_VALUE = 0
let COMMENT_INT_VALUE = 1
let FOLLOW_INT_VALUE = 2
let COMMENT_MENTION_INT_VALUE = 3
let POST_MENTION_INT_VALUE = 4
