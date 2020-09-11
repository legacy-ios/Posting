//
//  NotificationVC.swift
//  Posting
//
//  Created by jungwooram on 2020-05-18.
//  Copyright © 2020 jungwooram. All rights reserved.
//

import UIKit

private let reuseIdentifire = "NotificationCell"

class NotificationVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //clear separator lines
        tableView.separatorColor = .clear
        
        //register cell
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifire)
        
        //configure tableview
        navigationItem.title = "Notifications"
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifire, for: indexPath)
        return cell
    }
}
