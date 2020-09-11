//
//  UserProfileHeader.swift
//  Posting
//
//  Created by jungwooram on 2020-05-19.
//  Copyright © 2020 jungwooram. All rights reserved.
//

import UIKit
import Firebase



class UserProfileHeader: UICollectionViewCell {
    
    //MARK: - Properties
    
    weak var delegate: UserProfileHeaderDelegate?
    
    var user: User? {
        didSet {
            
            //configure edit profile button
            configureEditProfileFollowButton()
            
            // set user stats
            setUserStats(for: user)
            
            let fullname = user?.name
            
            nameLabel.text = fullname
            
            guard let url = user?.profileImageUrl else { return }
            
            profileImageView.loadImage(urlString: url)
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.layer.cornerRadius = 80 / 2
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    let postLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "5\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        return label
    }()
    
    lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        
        // add gesture recognizer
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        followTap.numberOfTapsRequired = 1
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        
        return label
    }()
    
    lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        
        // add gesture recognizer
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        followTap.numberOfTapsRequired = 1
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        
        return label
    }()
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        return button
    }()
    
    let gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        return button
    }()
    
    let listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let bookMarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    //MARK: - Helpers
    
    private func configureComponents() {
        
        //profile imageview
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 16, paddingLeft: 12, width: 80, height: 80)
        
        //name label
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, paddingTop: 12, width: 104)
        
        //post, followers, following label
        let stacklabel = UIStackView(arrangedSubviews: [postLabel, followersLabel, followingLabel])
        stacklabel.axis = .horizontal
        stacklabel.distribution = .fillEqually
        addSubview(stacklabel)
        stacklabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingRight: 0, height: 50)
        
        //edit profile button
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postLabel.bottomAnchor, left: postLabel.leftAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 8, paddingRight: 12, height: 30)
        
        //grid, list, bookmark buttons
        let topDividerView = UIView()
        topDividerView.backgroundColor = .lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = .lightGray
    
        let stackButton = UIStackView(arrangedSubviews: [gridButton, listButton, bookMarkButton])
        stackButton.axis = .horizontal
        stackButton.distribution = .fillEqually
        addSubview(stackButton)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackButton.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 50)
        topDividerView.anchor(top: stackButton.topAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
        bottomDividerView.anchor(top: stackButton.bottomAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
    }
    
    func configureEditProfileFollowButton() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let user = self.user else { return }
        
        if currentUid == user.uid {
        
            // configure button as edit profile
            editProfileFollowButton.setTitle("Edit Profile", for: .normal)
            
        } else {
            
            // configure button as follow button
            editProfileFollowButton.setTitleColor(.white, for: .normal)
            editProfileFollowButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            
            //유저가 팔로우하는 유저인지 아닌지 체크
            user.checkIfUserIsFollowed(completion: { followed in
                            
                if followed {
                    self.editProfileFollowButton.setTitle("Following", for: .normal)
                } else {
                    self.editProfileFollowButton.setTitle("Follow", for: .normal)
                }
                
            })
            
        }
    }
    
    // MARK: - Handlers
    
    @objc func handleFollowersTapped() {
        delegate?.handleFollowersTapped(for: self)
    }
    
    @objc func handleFollowingTapped() {
        delegate?.handleFollowingTapped(for: self)
    }
    
    @objc func handleEditProfileFollow() {        
        delegate?.handleEditFollowTapped(for: self)
    }
    
    func setUserStats(for user: User?) {
        delegate?.setUserStats(for: self)
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureComponents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
