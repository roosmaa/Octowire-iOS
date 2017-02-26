//
//  EventsState.swift
//  Octowire
//
//  Created by Mart Roosmaa on 24/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import Foundation
import ReSwift

enum EventsFilter {
    case repoEvents
    case starEvents
    case pullRequestEvents
    case forkEvents
}

struct EventsBrowserState: StateType {
    var scrollTopDistance: Float32 = 0
    var isRealtime: Bool = true
    
    var isPreloadingEvents: Bool = false
    var preloadedEvents: [(EventModel, eta: UInt16)] = []
    
    var activeFilters: [EventsFilter] = []
    var unfilteredEvents: [EventModel] = []
    var filteredEvents: [EventModel] = []
}
