//
//  UserProfileViewController.swift
//  Octowire
//
//  Created by Mart Roosmaa on 25/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {
    public var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.username
    }
}
