//
//  EventsReducer.swift
//  Octowire
//
//  Created by Mart Roosmaa on 24/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import Foundation
import ReSwift

struct EventsReducer: Reducer {
    func handleAction(action: Action, state: EventsState?) -> EventsState {
        var state = state ?? EventsState(
            scrollTopDistance: 0,
            isRealtime: true,
            visibleEvents: [],
            isLoadingEvents: false,
            upcomingEvents: [])
        
        switch action {
        default:
            break
        }
        
        return state
    }
}
