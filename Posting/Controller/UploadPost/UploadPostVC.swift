//
//  UploadPostVC.swift
//  Posting
//
//  Created by jungwooram on 2020-05-18.
//  Copyright © 2020 jungwooram. All rights reserved.
//

import UIKit
import Firebase

class UploadPostVC: UIViewController {

    //MARK: - Properties
    
    var selectedImage: UIImage?
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .blue
        return iv
    }()
    
    let captionTextView: UITextView = {
        let tv = UITextView()
        if #available(iOS 13.0, *) {
            tv.backgroundColor = .tertiarySystemGroupedBackground
        } else {
            // Fallback on earlier versions
        }
        tv.font = UIFont.systemFont(ofSize: 12)
        return tv
    }()
    
    let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = BUTTON_COLOR_DISABLE
        button.setTitle("Share", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleSharePost), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureViewComponents()
        
        loadImage()
        
        view.backgroundColor = .white
        
        captionTextView.delegate = self

    }
    
    //MARK: - Handlers
    
    func updateUserFeeds(with postId: String) {
        
        //current user id
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        //database values
        let values = [postId: 1]
        
        //update follower feeds
        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { snapshot in
            let followerUid = snapshot.key
            USER_FEED_REF.child(followerUid).updateChildValues(values)
        }
        
        //update current user feed
        USER_FEED_REF.child(currentUid).updateChildValues(values)
    }
    
    @objc func handleSharePost() {
        
        // paramaters
        guard
            let caption = captionTextView.text,
            let postImg = photoImageView.image,
            let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // image upload data
        guard let uploadData = postImg.jpegData(compressionQuality: 0.5) else { return }
        
        
        //creation date
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        //update storage
        let filename = NSUUID().uuidString
        let storageRef = STORAGE_POST_IMAGES_REF.child(filename)
        
        storageRef.putData(uploadData, metadata: nil) { metadata, error in
            
            //handle error
            if let error = error {
                print("Failed to upload to storage with error",error.localizedDescription)
                return
            }
            
            storageRef.downloadURL { url, error in
                
                guard let imageUrl = url?.absoluteString else { return }
                
                //post data
                let values = ["caption": caption,
                              "creationDate": creationDate,
                              "likes": 0,
                              "imageUrl": imageUrl,
                              "ownerUid": currentUid] as [String: Any]
                //post id
                let postId = POSTS_REF.childByAutoId()
                guard let postKey = postId.key else { return }
                
                //upload infomation to database
                postId.updateChildValues(values) { (err, ref) in
                    
                    
                    //update user-post structures
                    let userPostsRef = USER_POSTS_REF.child(currentUid)
                    userPostsRef.updateChildValues([postKey: 1])
                    
                    //update user-feed structure
                    self.updateUserFeeds(with: postKey)
                    
                    //return to home feed
                    self.dismiss(animated: true) {
                        self.tabBarController?.selectedIndex = 0
                    }
                }
            }
        }
        
        
            
    }
    
    //MARK: Helpers
    
    func configureViewComponents() {
        
        view.addSubview(photoImageView)
        photoImageView.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 102, paddingLeft: 12, width: 100, height: 100)
        
        view.addSubview(captionTextView)
        captionTextView.anchor(top: view.topAnchor, left: photoImageView.rightAnchor, right: view.rightAnchor, paddingTop: 102, paddingLeft: 12, paddingRight: 12, height: 100)
        
        view.addSubview(shareButton)
        shareButton.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 12, paddingLeft: 24, paddingRight: 24, height: 40)
    }
    
    func loadImage() {
        guard let selectecImage = self.selectedImage else { return }
        photoImageView.image = selectecImage
    }

}

extension UploadPostVC: UITextViewDelegate {
   
    func textViewDidChange(_ textView: UITextView) {
        
        guard !textView.text.isEmpty else {
            shareButton.isEnabled = false
            shareButton.backgroundColor = BUTTON_COLOR_DISABLE
            return
        }
        
        shareButton.isEnabled = true
        shareButton.backgroundColor = BUTTON_COLOR_ENABLE
    }
}
