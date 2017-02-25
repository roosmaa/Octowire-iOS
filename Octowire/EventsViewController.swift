//
//  EventsViewController.swift
//  Octowire
//
//  Created by Mart Roosmaa on 25/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import UIKit
import ReSwift

class EventsViewController: UIViewController {
    @IBOutlet weak var filterRepoButton: UIButton!
    @IBOutlet weak var filterStarButton: UIButton!
    @IBOutlet weak var filterPullRequestButton: UIButton!
    @IBOutlet weak var filterForkButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        mainStore.subscribe(self) { $0.eventsState }
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mainStore.unsubscribe(self)
        super.viewWillDisappear(animated)
    }
}

extension EventsViewController: StoreSubscriber {
    func newState(state: EventsState) {
        
    }
}
