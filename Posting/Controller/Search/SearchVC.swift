//
//  SearchVC.swift
//  Posting
//
//  Created by jungwooram on 2020-05-18.
//  Copyright © 2020 jungwooram. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifire = "SearchUserCell"

class SearchVC: UITableViewController {

    //MARK: - Properties
    var users = [User]()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configure
        configure()
                
        //fetch users
        fetchUsers()
    }

    //MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifire, for: indexPath) as! SearchUserCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[indexPath.row]
        
        // create instance of user profile vc
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        // passes user from searchVC to userprofieVC
        userProfileVC.user = user

        //push view controller
        navigationController?.pushViewController(userProfileVC, animated: true)
    }

    //MARK: - Helpers
    
    func configure() {
        //register cell class
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifire)
        
        //separator insets
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
        
        navigationItem.title = "Explore"

    }
    
    //MARK: - API
    
    func fetchUsers() {
        
        Database.database().reference().child("users").observe(.childAdded) { snapshot in
            
            let uid = snapshot.key
            
            Database.fetchUser(with: uid) { user in
                //append user to data source
                self.users.append(user)
                self.tableView.reloadData()
            }
        }
    }

}


