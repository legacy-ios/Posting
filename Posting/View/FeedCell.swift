//
//  FeedCell.swift
//  Posting
//
//  Created by jungwooram on 2020-06-03.
//  Copyright © 2020 jungwooram. All rights reserved.
//

import UIKit
import Firebase

class FeedCell: UICollectionViewCell {
    
    weak var delegate: FeedCellDelegate?
    
    var post: Post? {
        
        didSet {
            
            guard let ownerUid = post?.ownerUid else { return }
            guard let imageUrl = post?.imageUrl else { return }
            guard let likes = post?.likes else { return }
            
            Database.fetchUser(with: ownerUid) { user in
                self.profileImageView.loadImage(urlString: user.profileImageUrl)
                self.usernameButton.setTitle(user.username, for: .normal)
                self.configurePostCaption(user: user)
            }
            
            postImageView.loadImage(urlString: imageUrl)
            likesLabel.text = "\(likes) likes"
            handleConfigureLikeButton()
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.layer.cornerRadius = 40 / 2
        return iv
    }()
    
    lazy var usernameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Username", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleUsernameTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleOptionsTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        
        // add gesture recognizer
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(handelDoubleTapToLike))
        likeTap.numberOfTapsRequired = 2
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(likeTap)
        
        return iv
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleCommetTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var messageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleMessageTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var savePostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleSavePostTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var likesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        
        // add gesture recognizer
        let likes = UITapGestureRecognizer(target: self, action: #selector(handelShowLikesUser))
        likes.numberOfTapsRequired = 1
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(likes)
        
        return label
    }()
    
    let captionLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let postTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 10)
        label.text = "2 DAYS AGO"
        return label
    }()
    
    func configureActionButtons() {
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, messageButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: postImageView.bottomAnchor, width: 120, height: 50)
    }

    func configurePostCaption(user: User?) {
        
        guard let post = self.post else { return }
        guard let caption = post.caption else { return }
        guard let username = user?.username else { return }
        
        let attributedText = NSMutableAttributedString(string: "\(username) ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13)])
        attributedText.append(NSAttributedString(string: caption, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        captionLabel.attributedText = attributedText

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        postImageView.image = nil
        profileImageView.image = nil
        usernameButton.setTitle("", for: .normal)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8, width: 40, height: 40)
        
        addSubview(usernameButton)
        usernameButton.anchor(left: profileImageView.rightAnchor, paddingLeft: 8)
        usernameButton.centerY(inView: profileImageView)
        
        addSubview(optionsButton)
        optionsButton.anchor(right: rightAnchor, paddingRight: 8)
        optionsButton.centerY(inView: profileImageView)
        
        addSubview(postImageView)
        postImageView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 8)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        configureActionButtons()
        
        addSubview(savePostButton)
        savePostButton.anchor(top: postImageView.bottomAnchor, right: rightAnchor, paddingTop: 12, paddingRight: 8, width: 20, height: 24)
        
        addSubview(likesLabel)
        likesLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, paddingTop: -4, paddingLeft: 8)
        
        addSubview(captionLabel)
        captionLabel.anchor(top: likesLabel.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8)
        
        addSubview(postTimeLabel)
        postTimeLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleUsernameTapped() {
        delegate?.handleUsernameTapped(for: self)
    }
    
    @objc func handleOptionsTapped() {
        delegate?.handleOptionsTapped(for: self)
    }
    
    @objc func handleCommetTapped() {
        delegate?.handleCommentTapped(for: self)
    }
    
    @objc func handleMessageTapped() {
        delegate?.handleMessageTapped(for: self)
    }
    
    @objc func handleLikeTapped() {
        delegate?.handleLikeTapped(for: self, isDoubleTap: false)
    }
    
    @objc func handleSavePostTapped() {
        delegate?.handleSavePostTapped(for: self)
    }
    
    @objc func handelShowLikesUser() {
        delegate?.handelShowLikesUser(for: self)
    }
    
    @objc func handelDoubleTapToLike() {
        delegate?.handleLikeTapped(for: self, isDoubleTap: true)
    }
    
    func handleConfigureLikeButton() {
        delegate?.handleConfigureLikeButton(for: self)
    }
    
}
