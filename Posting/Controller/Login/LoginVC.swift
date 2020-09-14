//
//  LoginVC.swift
//  Posting
//
//  Created by jungwooram on 2020-05-18.
//  Copyright © 2020 jungwooram. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    //MARK: - Properties

    private let logoContainerView: UIView = {
        let view = UIView()
        //let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        //logoImageView.contentMode = .scaleAspectFill
        //view.addSubview(logoImageView)
        view.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 175/255, alpha: 1)
        //logoImageView.centerX(inView: view)
        //logoImageView.centerY(inView: view)
        return view
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
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = BUTTON_COLOR_DISABLE
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogUserIn), for: .touchUpInside)
        return button
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let atts: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.lightGray, .font: UIFont.systemFont(ofSize: 15)]
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account? ",
                                                        attributes: atts)
        let boldAtts: [NSAttributedString.Key: Any] = [.foregroundColor: BUTTON_COLOR_ENABLE, .font: UIFont.boldSystemFont(ofSize: 15)]
        attributedTitle.append(NSAttributedString(string: "Sign Up",
                                                  attributes: boldAtts))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSingUp), for: .touchUpInside)
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
    
    @objc func handleLogUserIn() {
        
        //properties
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        //sign user in with email and password
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            
            //handle error
            if let error = error {
                print("Unable to sign user in with error, \(error.localizedDescription)")
                return
            }
            
            guard let mainTabVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabVC else { return }
            
            // configure view controllers in maintabvc
            mainTabVC.configureViewController()
            
            //handle success
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleShowSingUp() {
        let controller = SignUpVC()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func formValidation() {
        
        //ensures that email and password text fields have text
        guard
            emailTextField.hasText,
            passwordTextField.hasText else {
                
                //handle case for above conditions not met
                loginButton.isEnabled = false
                loginButton.backgroundColor = BUTTON_COLOR_DISABLE
                return
        }
        
        //handle case for condition were met
        loginButton.isEnabled = true
        loginButton.backgroundColor = BUTTON_COLOR_ENABLE
        
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
        //logo
        view.addSubview(logoContainerView)
        logoContainerView.setHeight(height: 150)
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
        
        //email and password textfield and loginbutton
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingRight: 40, height: 150)
        
        //don't have account button
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.setHeight(height: 50)
        dontHaveAccountButton.anchor(bottom: view.bottomAnchor, paddingBottom: 20)
    }
}
