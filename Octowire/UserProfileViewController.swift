//
//  UserProfileViewController.swift
//  Octowire
//
//  Created by Mart Roosmaa on 25/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

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
    fileprivate var user: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.avatarImage.layer.cornerRadius = 10.0
        self.avatarImage.image = nil
        self.nameLabel.isHidden = true
        self.usernameLabel.isHidden = true
        self.bioLabel.isHidden = true
        setRowIsHidden(self.locationRow, to: true)
        setRowIsHidden(self.emailRow, to: true)
        setRowIsHidden(self.websiteRow, to: true)
        
        self.title = self.username
        
        self.emailRow.isUserInteractionEnabled = true
        var tapGesture = UITapGestureRecognizer(target: self, action: #selector(rowTapped))
        tapGesture.numberOfTapsRequired = 1
        self.emailRow.addGestureRecognizer(tapGesture)
        
        self.websiteRow.isUserInteractionEnabled = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(rowTapped))
        tapGesture.numberOfTapsRequired = 1
        self.websiteRow.addGestureRecognizer(tapGesture)
    }
    
    fileprivate func setRowIsHidden(_ row: UIView, to isHidden: Bool) {
        row.isHidden = isHidden
        // To avoid weird constraint warnings, we need to also zero out the
        // layoutMargins of the row.
        if isHidden {
            row.layoutMargins = UIEdgeInsets.zero
        } else {
            row.layoutMargins = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
        }
    }
    
    fileprivate func setProfileLabelText(_ label: UILabel, text: String?) {
        let text = text ?? ""
        
        if text != "" {
            label.text = text
            label.isHidden = false
        } else {
            label.isHidden = true
        }
    }
    
    @objc
    private func rowTapped(sender: UITapGestureRecognizer) {
        guard let user = self.user else {
            return
        }
        
        if sender.view == self.emailRow {
            let email = user.email ?? ""
            if email != "" {
                let mailto = URL(string: "mailto:\(email)")!
                if UIApplication.shared.canOpenURL(mailto) {
                    UIApplication.shared.open(mailto, options: [:], completionHandler: nil)
                } else {
                    mainStore.dispatch(showToast(type: .error, message: "Unable to open the mail client"))
                }
            }
            
        } else if sender.view == self.websiteRow {
            if var website = user.website?.absoluteString {
                if !website.hasPrefix("http://") && !website.hasPrefix("https://") {
                    website = "http://\(website)"
                }
                
                if let url = URL(string: website) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        mainStore.dispatch(showToast(type: .error, message: "Unable to open the website"))
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mainStore.dispatch(loadUserProfile(username: self.username))
        mainStore.subscribe(self) { (state: AppState) -> UserModel? in
            return state.userProfileState.users
                .first(where: { $0.username == self.username })
        }
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mainStore.unsubscribe(self)
        
        super.viewWillDisappear(animated)
    }
}

extension UserProfileViewController: StoreSubscriber {
    func newState(state: UserModel?) {
        guard let user = state else {
            return
        }
        
        self.user = user
        self.avatarImage.kf.setImage(with: user.avatarUrl,
                                     placeholder: #imageLiteral(resourceName: "AvatarPlaceholder"),
                                     options: nil,
                                     progressBlock: nil,
                                     completionHandler: nil)
        self.setProfileLabelText(self.nameLabel, text: user.name)
        self.setProfileLabelText(self.usernameLabel, text: user.username)
        self.setProfileLabelText(self.bioLabel, text: user.bio)
        
        let location = user.location ?? ""
        if location != "" {
            self.locationLabel.text = location
            self.setRowIsHidden(self.locationRow, to: false)
        } else {
            self.setRowIsHidden(self.locationRow, to: true)
        }
        
        let email = user.email ?? ""
        if email != "" {
            self.emailLabel.text = email
            self.setRowIsHidden(self.emailRow, to: false)
        } else {
            self.setRowIsHidden(self.emailRow, to: true)
        }
        
        let website = user.website?.absoluteString ?? ""
        if website != "" {
            self.websiteLabel.text = website
            self.setRowIsHidden(self.websiteRow, to: false)
        } else {
            self.setRowIsHidden(self.websiteRow, to: true)
        }
    }
}
