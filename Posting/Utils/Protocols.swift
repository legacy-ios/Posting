//
//  Protocols.swift
//  Posting
//
//  Created by jungwooram on 2020-06-01.
//  Copyright © 2020 jungwooram. All rights reserved.
//

import Foundation

protocol UserProfileHeaderDelegate: class {
    func handleEditFollowTapped(for header: UserProfileHeader)
    func setUserStats(for header: UserProfileHeader)
    func handleFollowersTapped(for header: UserProfileHeader)
    func handleFollowingTapped(for header: UserProfileHeader)
}

protocol FollowCellDelegate: class {
    func handleFollowTapped(for cell: FollowLikeCell)
}

protocol FeedCellDelegate: class {
    func handleUsernameTapped(for cell: FeedCell)
    func handleOptionsTapped(for cell: FeedCell)
    func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool)
    func handleCommentTapped(for cell: FeedCell)
    func handleMessageTapped(for cell: FeedCell)
    func handleSavePostTapped(for cell: FeedCell)
    func handelShowLikesUser(for cell: FeedCell)
    func handleConfigureLikeButton(for cell: FeedCell)
}
