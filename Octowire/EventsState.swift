//
//  EventsState.swift
//  Octowire
//
//  Created by Mart Roosmaa on 24/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import Foundation
import ReSwift

struct EventsState: StateType {
    var scrollTopDistance: Float32
    var isRealtime: Bool
    var visibleEvents: [Any]
    var isLoadingEvents: Bool
    var upcomingEvents: [Any]
}
