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

struct EventsState: StateType {
    var scrollTopDistance: Float32
    var isRealtime: Bool
    var activeFilters: [EventsFilter]
    var events: [Any]
    var isLoadingEvents: Bool
    var preloadedEvents: [Any]
}
