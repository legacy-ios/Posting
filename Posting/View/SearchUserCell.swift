//
//  SearchUserCell.swift
//  Posting
//
//  Created by jungwooram on 2020-05-19.
//  Copyright © 2020 jungwooram. All rights reserved.
//

import UIKit

class SearchUserCell: UITableViewCell {

    //MARK: - Properties

    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else { return }
            guard let username = user?.username else { return }
            guard let fullname = user?.name else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
            textLabel?.text = username
            detailTextLabel?.text = fullname
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor,paddingTop: 12, paddingLeft: 12, width: 48, height: 48)
        profileImageView.centerY(inView: contentView)
        
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
