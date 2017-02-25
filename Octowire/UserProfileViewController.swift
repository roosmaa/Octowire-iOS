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
        mainStore.dispatch(showToast(type: .info, message: "Rodger, rodger.. reversing!", duration: 1.5))
        mainStore.dispatch(NavigationActionStackPop())
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        mainStore.dispatch(showToast(type: .error, message: "Hi John!"))
        mainStore.dispatch(NavigationActionStackPush(route: .userProfile(username: "John")))
    }
}
