//
//  FeedVc.swift
//  Posting
//
//  Created by jungwooram on 2020-05-18.
//  Copyright © 2020 jungwooram. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "FeedCell"

class FeedVC: UICollectionViewController {

    
    //MARK: - Properties
    
    var posts = [Post]()
    var viewSinglePost = false
    var post: Post?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        collectionView.backgroundColor = .white
        
        // Register cell classes
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //configure refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(configureRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        //configure logout button
        configureNavigationBar()
        
        //fetch data
        if let post = self.post {
            posts.append(post)
        } else {
            fetchPosts()
        }
        
        //update feeds
        updateUserFeeds()
    }
    
    //MARK: - Helpers
    
    func configureNavigationBar() {
        
        if !viewSinglePost {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogOut))
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"), style: .plain, target: self, action: #selector(handleShowMessages))
        
        navigationItem.title = "Feed"
    }
    
    //MARK: - Selectors
    
    @objc func configureRefresh() {
        posts.removeAll(keepingCapacity: false)
        fetchPosts()
        collectionView.reloadData()
    }
    
    @objc func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            do{
                try Auth.auth().signOut()
                let navController = UINavigationController(rootViewController: LoginVC())
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
                
            } catch {
                print(error.localizedDescription)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func handleShowMessages() {
        print("handleShowMessages")
    }
    
    //MARK: - API
    
    func updateUserFeeds() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        //팔로잉 게시물
        USER_FOLLOWING_REF.child(currentUid).observe(.childAdded) { snapshot in
            
            let followingUserId = snapshot.key
            
            USER_POSTS_REF.child(followingUserId).observe(.childAdded) { snapshot in
                
                let postId = snapshot.key
                
                USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
            }
        }
        
        //자기 게시물
        USER_POSTS_REF.child(currentUid).observe(.childAdded) { snapshot in
            
            let postId = snapshot.key
            
            USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
        }
        
    }
    
    func fetchPosts() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_FEED_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            
            let postId = snapshot.key
            
            Database.fetchPost(with: postId) { post in
                
                self.posts.append(post)
                
                self.posts.sort { $0.creationDate > $1.creationDate }
                
                //stop refreshing
                self.collectionView.refreshControl?.endRefreshing()
                
                self.collectionView.reloadData()
                
            }
        }
    }

    //MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        
        cell.delegate = self

        cell.post = posts[indexPath.row]
        
        return cell
    }

}

extension FeedVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height = width + 8 + 40 + 8 + 50 + 60
        return CGSize(width: width, height: height)
    }
}

//MARK: - FeedCellDelegate
extension FeedVC: FeedCellDelegate {
    func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool) {
        
        guard let post = cell.post else { return }
        
        if post.didlike { // 이미 like 되어 있고
            if !isDoubleTap { // 더블탭이 아닌 하트버튼 클릭 like 해제
                //handle unlike post
                post.adjustLikes(addLike: false) { likes in
                    cell.likesLabel.text = "\(likes) likes"
                    cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
                }
            }
        } else {
            //handle like post
            post.adjustLikes(addLike: true) { likes in
                cell.likesLabel.text = "\(likes) likes"
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
            }
        }
    }
    
    
    func handleConfigureLikeButton(for cell: FeedCell) {
        guard let post = cell.post else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_LIKES_REF.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            
            if snapshot.hasChild(post.postId) {
                post.didlike = true
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
            } else {
                post.didlike = false
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
            }
        }
    }
    
    func handelShowLikesUser(for cell: FeedCell) {
        guard let post = cell.post else { return }
        guard let postId = post.postId else { return }
        
        let followLikeVC = FollowLikeVC()
        followLikeVC.viewingMode = FollowLikeVC.ViewingMode(index: 2)
        followLikeVC.postId = postId
        navigationController?.pushViewController(followLikeVC, animated: true)
    }
    
    func handleMessageTapped(for cell: FeedCell) {
        print("handleMessageTapped")
    }
    
    func handleSavePostTapped(for cell: FeedCell) {
        print("handlesavePostTapped")
    }
    
    func handleUsernameTapped(for cell: FeedCell) {
        
        guard let post = cell.post else { return }
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        userProfileVC.user = post.user
        
        navigationController?.pushViewController(userProfileVC, animated: true)
        
    }
    
    func handleOptionsTapped(for cell: FeedCell) {
        print("handleOptionsTapped")

    }
    
    func handleCommentTapped(for cell: FeedCell) {
        guard let postId = cell.post?.postId else { return }
        let commentVC = CommentVC(collectionViewLayout: UICollectionViewFlowLayout())
        commentVC.postId = postId
        navigationController?.pushViewController(commentVC, animated: true)
    }
    
}
