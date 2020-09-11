//
//  FollowCell.swift
//  Posting
//
//  Created by jungwooram on 2020-06-01.
//  Copyright © 2020 jungwooram. All rights reserved.
//

import UIKit
import Firebase

class FollowLikeCell: UITableViewCell {
    
    //MARK: - Properties
    weak var delegate: FollowCellDelegate?
    
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else { return }
            guard let username = user?.username else { return }
            guard let fullname = user?.name else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
            textLabel?.text = username
            detailTextLabel?.text = fullname
            
            // hide follow button for current user
            if user?.uid == Auth.auth().currentUser?.uid {
                followButton.isHidden = true
            }
            user?.checkIfUserIsFollowed(completion: { followed in
                if followed {
                    self.followButton.setTitle("Following", for: .normal)
                    self.followButton.setTitleColor(.black, for: .normal)
                    self.followButton.backgroundColor = .white
                    self.followButton.layer.borderWidth = 0.5
                    self.followButton.layer.borderColor = UIColor.lightGray.cgColor
                } else {
                    self.followButton.setTitle("Follow", for: .normal)
                    self.followButton.setTitleColor(.white, for: .normal)
                    self.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
                    self.followButton.layer.borderWidth = 0
                }
            })
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.layer.cornerRadius = 48 / 2
        return iv
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: - Handlers
    
    @objc func handleFollowTapped() {
        delegate?.handleFollowTapped(for: self)
    }

    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor,paddingTop: 12, paddingLeft: 12, width: 48, height: 48)
        profileImageView.centerY(inView: contentView)
        
        addSubview(followButton)
        followButton.anchor(right: rightAnchor, paddingRight: 12, width: 90, height: 30)
        followButton.centerY(inView: contentView)
        
        self.selectionStyle = .none
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y - 2, width: (textLabel?.frame.width)!, height: textLabel!.frame.height)
        textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        
        detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y - 2, width: self.frame.width - 108, height: detailTextLabel!.frame.height)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        detailTextLabel?.textColor = .lightGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
