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
    private let unfilteredEventsCapacity: Int
    
    init(unfilteredEventsCapacity: Int = 300) {
        self.unfilteredEventsCapacity = unfilteredEventsCapacity
    }
    
    func handleAction(action: Action, state: EventsBrowserState?) -> EventsBrowserState {
        var state = state ?? EventsBrowserState()
        
        switch action {
        case let action as EventsBrowserActionUpdateScrollTopDistance:
            state.scrollTopDistance = max(0, action.distance)
            
        case let action as EventsBrowserActionUpdateIsVisible:
            state.isVisible = action.isVisible
            
        case let action as EventsBrowserActionUpdateActiveFilters:
            state.activeFilters = action.filters
            state.filteredEvents = applyFilters(state.activeFilters, to: state.unfilteredEvents)
            
        case _ as EventsBrowserActionRevealPreloaded:
            // Increment the ETA for each item in the preloadedEvents array by 1,
            // items that reach 0 are removed and prepended to unfilteredEvents
            var futureEvents: [(EventModel, eta: UInt16)] = []
            var nextEvents: [EventModel] = []
            
            futureEvents.reserveCapacity(state.preloadedEvents.count)
            for t in state.preloadedEvents {
                let (ev, eta) = (t.0, t.eta - 1)
                if eta > 0 {
                    futureEvents.append((ev, eta))
                } else {
                    nextEvents.append(ev)
                }
            }
            
            state.preloadedEvents = futureEvents
            if !nextEvents.isEmpty {
                // Determine how many events to copy over from the old unfilteredEvents
                // so that the unfilteredEventsCapacity would be respected
                let copyOverEventsCount = max(0, min(state.unfilteredEvents.count + nextEvents.count, unfilteredEventsCapacity) - nextEvents.count)
                
                var unfilteredEvents: [EventModel] = []
                unfilteredEvents.reserveCapacity(nextEvents.count + copyOverEventsCount)
                unfilteredEvents.append(contentsOf: nextEvents)
                unfilteredEvents.append(contentsOf: state.unfilteredEvents.prefix(copyOverEventsCount))
                
                state.unfilteredEvents = unfilteredEvents
                state.filteredEvents = applyFilters(state.activeFilters, to: state.unfilteredEvents)
            }
            
        case _ as EventsBrowserActionBeginPreloading:
            state.isPreloadingEvents = true
            
        case let action as EventsBrowserActionEndPreloading:
            state.isPreloadingEvents = false
            
            let etaAdjustment: Int
            if state.unfilteredEvents.isEmpty && state.preloadedEvents.isEmpty {
                // For initial load adjust event ETAs in a way that delivers first
                // event as soon as possible
                etaAdjustment = 1 - (action.preloadedEvents.map({ Int($0.eta) }).min() ?? 0)
            } else {
                // For consecutive loads, adjust ETAs so that they would respect
                // the already preloaded events
                etaAdjustment = (state.preloadedEvents.map({ Int($0.eta) }).max() ?? 0) + 1
            }
            
            var preloadedEvents: [(EventModel, eta: UInt16)] = []
            preloadedEvents.reserveCapacity(action.preloadedEvents.count + state.preloadedEvents.count)
            preloadedEvents.append(contentsOf: action.preloadedEvents
                .map({ ($0.0, eta: UInt16(Int($0.eta) + etaAdjustment)) }))
            preloadedEvents.append(contentsOf: state.preloadedEvents)
            
            state.preloadedEvents = preloadedEvents
            
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
