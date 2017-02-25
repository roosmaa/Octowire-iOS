//
//  UserProfileViewController.swift
//  Octowire
//
//  Created by Mart Roosmaa on 25/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    
    public var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = "Hi \(self.username)!"
    }
    
    @IBAction func backTapped(_ sender: Any) {
        mainStore.dispatch(NavigationActionStackPop())
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        mainStore.dispatch(NavigationActionStackPush(route: .userProfile(username: "John")))
    }
}
