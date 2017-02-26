//
//  EventsBrowserStateSpec.swift
//  Octowire
//
//  Created by Mart Roosmaa on 26/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import Foundation
import ReSwift
import Quick
import Nimble
@testable import Octowire

class EventsBrowserStateSpec: QuickSpec {
    override func spec() {
        describe("actions") {
            let store = Store<EventsBrowserState>(
                reducer: EventsBrowserReducer(unfilteredEventsCapacity: 2),
                state: nil)
            
            it("begin preloading") {
                store.dispatch(EventsBrowserActionBeginPreloading())
                expect(store.state.isPreloadingEvents).to(equal(true))
            }
            
            it("end preloading") {
                store.dispatch(EventsBrowserActionEndPreloading(preloadedEvents: [
                    (PullRequestEventModel(), eta: 4),
                    (CreateEventModel(), eta: 3),
                    (ForkEventModel(), eta: 1),
                    (WatchEventModel(), eta: 0)]))
                expect(store.state.isPreloadingEvents).to(equal(false))
                expect(store.state.preloadedEvents.map({ $0.eta })).to(equal([5, 4, 2, 1]))
            }
            
            it("reveals first preloaded event") {
                store.dispatch(EventsBrowserActionRevealPreloaded())
                expect(store.state.filteredEvents).to(haveCount(1))
                expect(store.state.filteredEvents[0]).to(beAnInstanceOf(WatchEventModel.self))
            }
            
            it("reveals next preloaded above others") {
                store.dispatch(EventsBrowserActionRevealPreloaded())
                expect(store.state.filteredEvents).to(haveCount(2))
                expect(store.state.filteredEvents[0]).to(beAnInstanceOf(ForkEventModel.self))
                expect(store.state.filteredEvents[1]).to(beAnInstanceOf(WatchEventModel.self))
            }
            
            it("reveals nothing due preload queue having a gap") {
                store.dispatch(EventsBrowserActionRevealPreloaded())
                expect(store.state.filteredEvents).to(haveCount(2))
                expect(store.state.filteredEvents[0]).to(beAnInstanceOf(ForkEventModel.self))
                expect(store.state.filteredEvents[1]).to(beAnInstanceOf(WatchEventModel.self))
            }
            
            it("reveals next hitting event capacity") {
                store.dispatch(EventsBrowserActionRevealPreloaded())
                expect(store.state.filteredEvents).to(haveCount(2))
                expect(store.state.filteredEvents[0]).to(beAnInstanceOf(CreateEventModel.self))
                expect(store.state.filteredEvents[1]).to(beAnInstanceOf(ForkEventModel.self))
            }
            
            it("updates scroll top distance") {
                store.dispatch(EventsBrowserActionUpdateScrollTopDistance(to: 100))
                expect(store.state.isRealtime).to(equal(false))
                expect(store.state.scrollTopDistance).to(equal(100))
                
                store.dispatch(EventsBrowserActionUpdateScrollTopDistance(to: -1))
                expect(store.state.isRealtime).to(equal(true))
                expect(store.state.scrollTopDistance).to(equal(0))
            }
            
            it("filters results") {
                store.dispatch(EventsBrowserActionUpdateActiveFilters(to: [.forkEvents]))
                expect(store.state.filteredEvents).to(haveCount(1))
                expect(store.state.unfilteredEvents).to(haveCount(2))
            }
            
            it("doesn't reveal filtered") {
                store.dispatch(EventsBrowserActionRevealPreloaded())
                expect(store.state.filteredEvents).to(haveCount(0))
                expect(store.state.unfilteredEvents).to(haveCount(2))
            }
        }
        
        describe("action creaters") {
            let store = Store<AppState>(
                reducer: AppReducer(),
                state: nil)
            
            it("loads events") {
                store.dispatch(loadNextEvent())
                expect(store.state.eventsBrowserState.isPreloadingEvents).to(be(true))
                expect(store.state.eventsBrowserState.isPreloadingEvents).toEventually(be(false), timeout: 5)
            }
        }
    }
}
