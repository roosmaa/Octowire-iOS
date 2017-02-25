//
//  EventsViewController.swift
//  Octowire
//
//  Created by Mart Roosmaa on 25/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController {
    @IBAction func nextTapped(_ sender: Any) {
        mainStore.dispatch(NavigationActionStackPush(route: .userProfile(username: "Jane")))
    }
}
