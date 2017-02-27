//
//  EventsBrowserActions.swift
//  Octowire
//
//  Created by Mart Roosmaa on 26/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRecorder
import Alamofire
import AlamofireObjectMapper

let eventsBrowserActionTypeMap: TypeMap = [
    EventsBrowserActionUpdateScrollTopDistance.type: EventsBrowserActionUpdateScrollTopDistance.self,
    EventsBrowserActionUpdateIsVisible.type: EventsBrowserActionUpdateIsVisible.self,
    EventsBrowserActionUpdateActiveFilters.type: EventsBrowserActionUpdateActiveFilters.self,
    EventsBrowserActionRevealPreloaded.type: EventsBrowserActionRevealPreloaded.self,
    EventsBrowserActionBeginPreloading.type: EventsBrowserActionBeginPreloading.self,
    EventsBrowserActionEndPreloading.type: EventsBrowserActionEndPreloading.self]

struct EventsBrowserActionUpdateScrollTopDistance: StandardActionConvertible {
    static let type = "EVENTS_BROWSER_ACTION_UPDATE_SCROLL_TOP_DISTANCE"
    
    let distance: Float32
    
    init(to distance: Float32) {
        self.distance = distance
    }
    
    init(_ standardAction: StandardAction) {
        self.distance = standardAction.payload!["distance"] as! Float32
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(
            type: EventsBrowserActionUpdateScrollTopDistance.type,
            payload: [
                "distance": self.distance as AnyObject],
            isTypedAction: true)
    }
}

struct EventsBrowserActionUpdateIsVisible: StandardActionConvertible {
    static let type = "EVENTS_BROWSER_ACTION_UPDATE_IS_VISIBLE"
    
    let isVisible: Bool
    
    init(to isVisible: Bool) {
        self.isVisible = isVisible
    }
    
    init(_ standardAction: StandardAction) {
        self.isVisible = standardAction.payload!["isVisible"] as! Bool
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(
            type: EventsBrowserActionUpdateIsVisible.type,
            payload: [
                "isVisible": self.isVisible as AnyObject],
            isTypedAction: true)
    }
}

struct EventsBrowserActionUpdateActiveFilters: StandardActionConvertible {
    static let type = "EVENTS_BROWSER_ACTION_UPDATE_ACTIVE_FILTERS"
    
    let filters: [EventsFilter]
    
    init(to filters: [EventsFilter]) {
        self.filters = filters
    }
    
    init(_ standardAction: StandardAction) {
        self.filters = decode(standardAction.payload!["filters"])
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(
            type: EventsBrowserActionUpdateActiveFilters.type,
            payload: [
                "filters": encode(self.filters)],
            isTypedAction: true)
    }
}

struct EventsBrowserActionRevealPreloaded: StandardActionConvertible {
    static let type = "EVENTS_BROWSER_ACTION_REVEAL_PRELOADED"
    
    init() {}
    
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(
            type: EventsBrowserActionRevealPreloaded.type,
            payload: nil,
            isTypedAction: true)
    }
}

struct EventsBrowserActionBeginPreloading: StandardActionConvertible {
    static let type = "EVENTS_BROWSER_ACTION_BEGIN_PRELOADING"
    
    init() {}
    
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(
            type: EventsBrowserActionBeginPreloading.type,
            payload: nil,
            isTypedAction: true)
    }
}

struct EventsBrowserActionEndPreloading: StandardActionConvertible {
    static let type = "EVENTS_BROWSER_ACTION_END_PRELOADING"
    
    let preloadedEvents: [(EventModel, eta: UInt16)]
    
    init(preloadedEvents: [(EventModel, eta: UInt16)]) {
        self.preloadedEvents = preloadedEvents
    }
    
    init(_ standardAction: StandardAction) {
        self.preloadedEvents = decode(standardAction.payload!["preloadedEvents"])
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(
            type: EventsBrowserActionEndPreloading.type,
            payload: [
                "preloadedEvents": encode(self.preloadedEvents)],
            isTypedAction: true)
    }
}

func loadNextEvent() -> Store<AppState>.ActionCreator {
    return { state, store in
        let state = state.eventsBrowserState
        
        guard state.isVisible && state.scrollTopDistance < 1 else {
            return nil
        }
        store.dispatch(EventsBrowserActionRevealPreloaded())
        
        if state.preloadedEvents.count <= 1 && !state.isPreloadingEvents {
            store.dispatch(EventsBrowserActionBeginPreloading())
            
            Alamofire
                .request("https://api.github.com/events",
                         headers: ["Accept": "application/vnd.github.v3+json"])
                .responseArray(completionHandler: { (resp: DataResponse<[EventModel]>) in
                    
                    let events: [(EventModel, eta: UInt16)]
                    
                    if let arr = resp.result.value {
                        events = arr
                            .enumerated()
                            .map({ (idx, ev) in (ev, eta: UInt16(arr.count - idx)) })
                            .filter({ (ev, _) in
                                switch ev {
                                case let ev as CreateEventModel:
                                    return ev.refType == .repository
                                    
                                case let ev as PullRequestEventModel:
                                    return ev.action == .opened
                                    
                                case _ as WatchEventModel: return true
                                case _ as ForkEventModel: return true
                                default: return false
                                }
                            })
                    } else {
                        events = []
                        
                        print("Failed to get events from GitHub: \(resp.error)")
                        store.dispatch(showToast(type: .error, message: "Unable to connect to GitHub"))
                    }
                    
                    store.dispatch(EventsBrowserActionEndPreloading(preloadedEvents: events))
                })
        }
        
        return nil
    }
}

private func encode(_ value: [EventsFilter]) -> AnyObject {
    let arr = value.map({ v -> String in
        switch v {
        case .repoEvents: return "repo"
        case .starEvents: return "star"
        case .pullRequestEvents: return "pullRequest"
        case .forkEvents: return "fork"
        }
    })
    return arr as AnyObject
}

private func decode(_ value: AnyObject?) -> [EventsFilter] {
    return (value as! [String]).flatMap({ v -> EventsFilter? in
        switch v {
        case "repo": return .repoEvents
        case "star": return .starEvents
        case "pullRequest": return .pullRequestEvents
        case "fork": return .forkEvents
        default: return nil
        }
    })
}

private func encode(_ value: [(EventModel, eta: UInt16)]) -> AnyObject {
    let arr = value.map({ v -> [String: AnyObject] in
        return [
            "event": v.0.toJSONString() as AnyObject,
            "eta": v.eta as AnyObject]
    })
    return arr as AnyObject
}

private func decode(_ value: AnyObject?) -> [(EventModel, eta: UInt16)] {
    return (value as! [[String: AnyObject]]).flatMap({ v -> (EventModel, eta: UInt16)? in
        guard let ev = EventModel(JSONString: v["event"] as! String) else {
            return nil
        }
        return (ev, eta: v["eta"] as! UInt16)
    })
}
