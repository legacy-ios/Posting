//
//  CommentVC.swift
//  Posting
//
//  Created by jungwooram on 2020-06-04.
//  Copyright © 2020 jungwooram. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "CommentCell"

class CommentVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    //MARK: - Properties
    
    var postId: String?
    var comments = [Comment]()
    
    lazy var containerView: UIView = {
        
        let containerView = UIView()
        
        containerView.frame = CGRect(x: 0, y: 0, width: 0, height: 50)
        
        if #available(iOS 13.0, *) {
            containerView.backgroundColor = .tertiarySystemGroupedBackground
        } else {
            // Fallback on earlier versions
        }
        
        containerView.addSubview(postButton)
        postButton.anchor(right: containerView.rightAnchor, paddingRight: 8, width: 50)
        postButton.centerY(inView: containerView)
        
        containerView.addSubview(commentTextField)
        commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: postButton.leftAnchor, paddingLeft: 8, paddingRight: 8)
                
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        containerView.addSubview(separatorView)
        separatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, right: containerView.rightAnchor, height: 0.1)
        
        return containerView
    }()
    
    let postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Post", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleUploadCommnet), for: .touchUpInside)
        return button
    }()
    
    let commentTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter commnet.."
        tf.font = UIFont.systemFont(ofSize: 14)
        if #available(iOS 13.0, *) {
            tf.backgroundColor = .tertiarySystemGroupedBackground
        } else {
            // Fallback on earlier versions
        }
        return tf
    }()
    
    //MARK: - Handlers
    @objc func handleUploadCommnet() {
        guard let postId = self.postId else { return }
        guard let commnetText = commentTextField.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let values = ["commentText": commnetText,
                      "creationDate": creationDate,
                      "uid": uid] as [String: Any]
        
        COMMENT_REF.child(postId).childByAutoId().updateChildValues(values) { err, ref in
            self.commentTextField.text = nil
        }
    }
    
    //MARK: - API
    func fetchComments() {
        guard let postId = self.postId else { return }
        COMMENT_REF.child(postId).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            Database.fetchUser(with: uid) { user in
                let comment = Comment(user: user, dictionary: dictionary)
                self.comments.append(comment)
                self.collectionView.reloadData()
            }
        }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configure collection view
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
        
        //configure naviation title
        navigationItem.title = "Comments"
        
        // Register cell classes
        self.collectionView!.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //fetch Comments
        fetchComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    //MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        cell.comment = comments[indexPath.row]
        return cell
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    
}
