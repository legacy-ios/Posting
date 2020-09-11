//
//  SignUpVC.swift
//  Posting
//
//  Created by jungwooram on 2020-05-18.
//  Copyright © 2020 jungwooram. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController {
    
    //MARK: - Properties
    var imageSelected = false
    
    let addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSelectProfilePhoto), for: .touchUpInside)
        return button
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    private let fullNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Full Name"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    private let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = BUTTON_COLOR_DISABLE
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    private let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let atts: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.lightGray, .font: UIFont.systemFont(ofSize: 15)]
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ",
                                                        attributes: atts)
        let boldAtts: [NSAttributedString.Key: Any] = [.foregroundColor: BUTTON_COLOR_ENABLE, .font: UIFont.boldSystemFont(ofSize: 15)]
        attributedTitle.append(NSAttributedString(string: "Log In",
                                                  attributes: boldAtts))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
   
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    //MARK: - Selectors
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSignUp() {
        
        //properties
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullNameTextField.text else { return }
        guard let username = usernameTextField.text?.lowercased() else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            
            // handle error
            if let error = error {
                print("Failded to create user with error: \(error.localizedDescription)")
                return
            }
            
            //set profile image
            guard let profileImage = self.addPhotoButton.imageView?.image else { return }
            
            //upload data
            guard let uploadData = profileImage.jpegData(compressionQuality: 0.3) else { return }
            
            //place image in firebase storage
            let filename = NSUUID().uuidString
            
            let storageRef = Storage.storage().reference().child("profile_images").child(filename)
            storageRef.putData(uploadData, metadata: nil) {  metadata, error in
                
                //handle error
                if let error = error {
                    print("Failed to upload image to Firebase Storage with error, \(error.localizedDescription)")
                }
                                
                //profile image url
                storageRef.downloadURL { downloadURL, error in
                    
                    guard let profileImageUrl = downloadURL?.absoluteString else {
                        print("DEBUG: Profile image url is nil")
                        return
                    }
                    
                    guard let uid = authResult?.user.uid else { return }
                    
                    let dictionaryValues = ["name": fullname,
                                            "username": username,
                                            "profileImageUrl": profileImageUrl]
                    
                    let values = [uid: dictionaryValues]
                    
                    // save user info to database
                    Database.database().reference().child("users").updateChildValues(values) { error, ref  in
                        
                        guard let mainTabVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabVC else { return }
                        
                        // configure view controllers in maintabvc
                        mainTabVC.configureViewController()
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                }
            }
            
        }
    }
    
    @objc func formValidation() {
        
        guard
            imageSelected,
            emailTextField.hasText,
            fullNameTextField.hasText,
            usernameTextField.hasText,
            passwordTextField.hasText else {
                signUpButton.isEnabled = false
                signUpButton.backgroundColor = BUTTON_COLOR_DISABLE
                return
        }
        
        signUpButton.isEnabled = true
        signUpButton.backgroundColor = BUTTON_COLOR_ENABLE
    }
    
    @objc func handleSelectProfilePhoto() {
        
        //configure image picker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        //present image picker
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        
        view.backgroundColor = .white
        
        //photoButton
        view.addSubview(addPhotoButton)
        addPhotoButton.centerX(inView: view)
        addPhotoButton.anchor(top: view.topAnchor, paddingTop: 40)
        addPhotoButton.setDimensions(height: 140, width: 140)
        
        //email,password,fullname textfield and signinbutton
        let stackView = UIStackView(arrangedSubviews: [emailTextField, fullNameTextField, usernameTextField, passwordTextField, signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.anchor(top: addPhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 24, paddingLeft: 40, paddingRight: 40)
        stackView.setHeight(height: 250)
        
        //alreadyHaveAccountButton
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.setHeight(height: 50)
        alreadyHaveAccountButton.anchor(bottom: view.bottomAnchor, paddingBottom: 20)
    }
}

extension SignUpVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //selected Image
        guard let profileImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            imageSelected = false
            return
        }
        
        imageSelected = true
        
        //configure addPhotoButton with selected Image
        addPhotoButton.layer.cornerRadius = addPhotoButton.frame.width / 2
        addPhotoButton.layer.masksToBounds = true
        addPhotoButton.layer.borderColor = UIColor.black.cgColor
        addPhotoButton.layer.borderWidth = 1
        addPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true, completion: nil)
    }
}

extension SignUpVC: UINavigationControllerDelegate {
    
}
