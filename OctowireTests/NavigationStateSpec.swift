//
//  NavigationSpec.swift
//  Octowire
//
//  Created by Mart Roosmaa on 24/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import Foundation
import ReSwift
import Quick
import Nimble
@testable import Octowire

class NavigationStateSpec: QuickSpec {
    override func spec() {
        describe("navigation actions") {
            let store = Store<NavigationState>(
                reducer: NavigationReducer(),
                state: nil)
            
            let r1: Route = .events
            it("set initial route") {
                store.dispatch(NavigationActionStackReplace(
                    routes: [r1],
                    animated: false))
                expect(store.state.stack).to(equal([r1]))
            }
            
            let r2: Route = .userProfile(username: "google")
            let r3: Route = .userProfile(username: "facebook")
            let r4: Route = .userProfile(username: "github")
            it("push routes") {
                store.dispatch(NavigationActionStackPush(
                    route: r2,
                    animated: true))
                expect(store.state.animationCounter).to(equal(1))
                store.dispatch(NavigationActionStackPush(
                    route: r3,
                    animated: true))
                expect(store.state.animationCounter).to(equal(2))
                expect(store.state.stack).to(equal([r1, r2, r3]))
                
                store.dispatch(NavigationActionStackPush(
                    route: r4,
                    animated: false))
                expect(store.state.animationCounter).to(equal(0))
                expect(store.state.stack).to(equal([r1, r2, r3, r4]))
            }
            
            it("pop routes") {
                store.dispatch(NavigationActionStackPop(animated: true))
                expect(store.state.animationCounter).to(equal(1))
                store.dispatch(NavigationActionStackPop(animated: true))
                expect(store.state.animationCounter).to(equal(2))
                expect(store.state.stack).to(equal([r1, r2]))
                
                store.dispatch(NavigationActionStackPop(animated: false))
                expect(store.state.animationCounter).to(equal(0))
                expect(store.state.stack).to(equal([r1]))
                
            }
            
            it("replace routes") {
                store.dispatch(NavigationActionStackReplace(
                    routes: [r2, r3],
                    animated: true))
                expect(store.state.animationCounter).to(equal(1))
                expect(store.state.stack).to(equal([r2, r3]))
                
                store.dispatch(NavigationActionStackReplace(
                    routes: [r4, r2],
                    animated: true))
                expect(store.state.animationCounter).to(equal(2))
                expect(store.state.stack).to(equal([r4, r2]))
                
                store.dispatch(NavigationActionStackReplace(
                    routes: [r1, r2, r3],
                    animated: false))
                expect(store.state.animationCounter).to(equal(0))
                expect(store.state.stack).to(equal([r1, r2, r3]))
            }
        }
    }
}
