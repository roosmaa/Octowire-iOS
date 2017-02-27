//
//  UserProfileViewController.swift
//  Octowire
//
//  Created by Mart Roosmaa on 25/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var locationRow: UIStackView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var emailRow: UIStackView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var websiteRow: UIStackView!
    @IBOutlet weak var websiteLabel: UILabel!
    
    public var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.avatarImage.layer.cornerRadius = 10.0
        self.nameLabel.isHidden = true
        self.usernameLabel.isHidden = true
        self.bioLabel.isHidden = true
        setRowIsHidden(self.locationRow, to: true)
        setRowIsHidden(self.emailRow, to: true)
        setRowIsHidden(self.websiteRow, to: true)
        
        self.title = self.username
    }
    
    private func setRowIsHidden(_ row: UIView, to isHidden: Bool) {
        row.isHidden = isHidden
        // To avoid weird constraint warnings, we need to also zero out the
        // layoutMargins of the row.
        if isHidden {
            row.layoutMargins = UIEdgeInsets.zero
        } else {
            row.layoutMargins = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
        }
    }
}
