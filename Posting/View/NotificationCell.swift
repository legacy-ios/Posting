//
//  NotificationCell.swift
//  Posting
//
//  Created by jungwooram on 2020-06-04.
//  Copyright © 2020 jungwooram. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    //MARK: - Properties
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let notificationLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "joker", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: " commented on your post", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        attributedText.append(NSAttributedString(string: " 2Days", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        label.numberOfLines = 2
        return label
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()
    
    let postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    //MARK: - Handlers
    
    @objc func handleFollowTapped() {
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor,paddingTop: 12, paddingLeft: 12, width: 40, height: 40)
        profileImageView.centerY(inView: contentView)
        profileImageView.layer.cornerRadius = 40 / 2
    
        addSubview(followButton)
        followButton.anchor(right: rightAnchor, paddingRight: 12, width: 90, height: 30)
        followButton.centerY(inView: contentView)
        followButton.layer.cornerRadius = 3
        followButton.isHidden = true
        
        addSubview(postImageView)
        postImageView.anchor(right: rightAnchor, paddingRight: 8, width: 40, height: 40)
        postImageView.centerY(inView: contentView)
        
        addSubview(notificationLabel)
        notificationLabel.anchor(left: profileImageView.rightAnchor, right: postImageView.leftAnchor, paddingLeft: 8, paddingRight: 8)
        notificationLabel.centerY(inView: contentView)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
