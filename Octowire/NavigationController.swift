//
//  ViewController.swift
//  Octowire
//
//  Created by Mart Roosmaa on 24/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import UIKit
import ReSwift

class NavigationController: UINavigationController {
    fileprivate var animationCounter: UInt64 = 0
    private var toastController: ToastController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        toastController = ToastController(viewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mainStore.subscribe(self)
        mainStore.subscribe(toastController)
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mainStore.unsubscribe(toastController)
        mainStore.unsubscribe(self)
        
        super.viewWillDisappear(animated)
    }
}

extension NavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        // Check if we're still in sync with the AppState, if not, try to
        // update the state to match this UINavigationController
        let routes = viewControllers.flatMap { vc in vc.route };
        if mainStore.state.navigationState.stack != routes {
            mainStore.dispatch(NavigationActionStackReplace(
                routes: routes, animated: false))
        }
    }
}

extension NavigationController: StoreSubscriber {
    func newState(state: AppState) {
        let navigationState = state.navigationState
        
        let animated = self.animationCounter < navigationState.animationCounter
        self.animationCounter = navigationState.animationCounter
        
        var viewControllers = self.viewControllers
        self.setViewControllers(navigationState.stack.map { route in
            if let idx = viewControllers.index(where: { $0.route == route }) {
                return viewControllers.remove(at: idx)
            } else {
                return route.initViewController()
            }
        }, animated: animated)
    }
}
