//
//  CommentCell.swift
//  Posting
//
//  Created by jungwooram on 2020-06-04.
//  Copyright © 2020 jungwooram. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    var comment: Comment? {
        didSet {
            
            guard let user = comment?.user else { return }
            guard let profileImageUrl = user.profileImageUrl else { return }
            guard let username = user.username else { return }
            guard let commentText = comment?.commentText else { return }
            
            profileImageView.loadImage(urlString: profileImageUrl)
            
            configureComment(username: username, commentText: commentText, creationDate: "")
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let commentTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 12)
        tv.isScrollEnabled = false
        return tv
    }()
    
    func configureComment(username: String, commentText: String, creationDate: String) {
        let attributedText = NSMutableAttributedString(string: "\(username)", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: " \(commentText)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        attributedText.append(NSAttributedString(string: " \(creationDate).", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        commentTextView.attributedText = attributedText
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor,paddingTop: 12, paddingLeft: 12, width: 40, height: 40)
        profileImageView.centerY(inView: self)
        profileImageView.layer.cornerRadius = 40 / 2
        
        addSubview(commentTextView)
        commentTextView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
