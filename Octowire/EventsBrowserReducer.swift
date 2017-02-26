//
//  EventsReducer.swift
//  Octowire
//
//  Created by Mart Roosmaa on 24/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import Foundation
import ReSwift

struct EventsBrowserReducer: Reducer {
    func handleAction(action: Action, state: EventsBrowserState?) -> EventsBrowserState {
        var state = state ?? EventsBrowserState()
        
        state.filteredEvents = applyFilters(state.activeFilters, to: state.unfilteredEvents)
        switch action {
        default:
            break
        }
        
        return state
    }
}

private func applyFilters(_ filters: [EventsFilter], to events: [EventModel]) -> [EventModel] {
    let includeAll = filters.isEmpty
    let includeRepoEvents = includeAll || filters.contains(.repoEvents)
    let includeStarEvents = includeAll || filters.contains(.starEvents)
    let includePullRequestEvents = includeAll || filters.contains(.pullRequestEvents)
    let includeForkEvents = includeAll || filters.contains(.forkEvents)
    
    return events.filter { ev in
        switch ev {
        case _ as CreateEventModel: return includeRepoEvents
        case _ as WatchEventModel: return includeStarEvents
        case _ as PullRequestEventModel: return includePullRequestEvents
        case _ as ForkEventModel: return includeForkEvents
        default: return false
        }
    }
}
