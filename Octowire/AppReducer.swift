//
//  AppReducer.swift
//  Octowire
//
//  Created by Mart Roosmaa on 24/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import Foundation
import ReSwift

struct AppReducer: Reducer {
    let toastReducer = ToastReducer()
    let eventsReducer = EventsReducer()
    let navigationReducer = NavigationReducer()
    
    func handleAction(action: Action, state: AppState?) -> AppState {
        return AppState(
            toastState: toastReducer.handleAction(action: action, state: state?.toastState),
            navigationState: navigationReducer.handleAction(action: action, state: state?.navigationState),
            eventsState: eventsReducer.handleAction(action: action, state: state?.eventsState))
    }
}