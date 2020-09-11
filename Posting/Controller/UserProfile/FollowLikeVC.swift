//
//  FollowVC.swift
//  Posting
//
//  Created by jungwooram on 2020-06-01.
//  Copyright © 2020 jungwooram. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifire = "FollowCell"

class FollowLikeVC: UITableViewController {
    
    //MARK: - Properties
    enum ViewingMode: Int {
        case Following
        case Followers
        case Likes
        
        init(index: Int) {
            switch index {
                case 0: self = .Followers
                case 1: self = .Following
                case 2: self = .Likes
                default: self = .Following
            }
        }
    }
    
    var postId: String?
    var viewingMode: ViewingMode?
    var uid: String?
    var users = [User]()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //register cell
        tableView.register(FollowLikeCell.self, forCellReuseIdentifier: reuseIdentifire)
        
        //clear separator line
        tableView.separatorColor = .clear
    
        //configureNavigation Title
        configureNavigationTitle()
        
        //fetch users
        fetchUsers()
    }
    
    //MARK: - UITableview
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = user
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifire, for: indexPath) as! FollowLikeCell
        cell.user = users[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    //MARK: - API
    
    func getDatabaseReference() -> DatabaseReference? {
        guard let viewingMode = self.viewingMode else { return nil }
        switch viewingMode {
            case .Followers: return USER_FOLLOWER_REF
            case .Following: return USER_FOLLOWING_REF
            case .Likes: return POST_LIKES_REF
        }
        
    }
    
    func fetchUsers() {
       
        guard let viewingMode = self.viewingMode else { return }
        guard let ref = getDatabaseReference() else { return }
        
        switch viewingMode {
        
        case .Followers, .Following:
            
            guard let uid = self.uid else { return }
            
            ref.child(uid).observeSingleEvent(of: .value) { snapshot in
                
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { snapshot in
                    let uid = snapshot.key
                    self.fetchUser(with: uid)
                }
        }
            
        case .Likes:
            guard let postId = self.postId else { return }
            ref.child(postId).observe(.childAdded) { snapshot in
                let uid = snapshot.key
                self.fetchUser(with: uid)
            }
        }
    }
    
    // MARK: - Helpers
    func fetchUser(with uid: String) {
        Database.fetchUser(with: uid) { user in
            self.users.append(user)
            self.tableView.reloadData()
        }
    }
    
    func configureNavigationTitle() {
        guard let viewingMode = self.viewingMode else { return }
        switch viewingMode {
            case .Followers: navigationItem.title = "Followers"
            case .Following: navigationItem.title = "Following"
            case .Likes: navigationItem.title = "Likes"
        }
    }
    
}

extension FollowLikeVC: FollowCellDelegate {
    
    func handleFollowTapped(for cell: FollowLikeCell) {
    
        guard let user = cell.user else { return }
        
        if user.isFollowed {
            user.unfollow()
            cell.followButton.setTitle("Follow", for: .normal)
            cell.followButton.setTitleColor(.white, for: .normal)
            cell.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            cell.followButton.layer.borderWidth = 0
        } else {
            user.follow()
            cell.followButton.setTitle("Following", for: .normal)
            cell.followButton.setTitleColor(.black, for: .normal)
            cell.followButton.backgroundColor = .white
            cell.followButton.layer.borderWidth = 0.5
            cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
}
