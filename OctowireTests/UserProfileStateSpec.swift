//
//  UserProfileSpec.swift
//  Octowire
//
//  Created by Mart Roosmaa on 27/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import Foundation
import ReSwift
import Quick
import Nimble
@testable import Octowire

class UserProfileStateSpec: QuickSpec {
    override func spec() {
        describe("actions") {
            let store = Store<UserProfileState>(
                reducer: UserProfileReducer(cachedProfilesCapacity: 2),
                state: nil)
            
            it("begins loading john") {
                store.dispatch(UserProfileActionBeginLoading(username: "john"))
                expect(store.state.loadingUsers).to(equal(["john"]))
            }
            
            it("ends loading john") {
                let user = UserModel()
                user.username = "john"
                
                store.dispatch(UserProfileActionEndLoading(username: "john", user: user))
                expect(store.state.loadingUsers).to(beEmpty())
                expect(store.state.users).to(containElementSatisfying({ $0.username == "john" }))
            }
            
            it("begins loading jane") {
                store.dispatch(UserProfileActionBeginLoading(username: "jane"))
                expect(store.state.loadingUsers).to(equal(["jane"]))
            }
            
            it("begins loading mary") {
                store.dispatch(UserProfileActionBeginLoading(username: "mary"))
                expect(store.state.loadingUsers).to(equal(["jane", "mary"]))
            }
            
            it("ends loading mary with failure") {
                store.dispatch(UserProfileActionEndLoading(username: "mary", user: nil))
                expect(store.state.loadingUsers).to(equal(["jane"]))
            }
            
            it("begins loading rick") {
                store.dispatch(UserProfileActionBeginLoading(username: "rick"))
                expect(store.state.loadingUsers).to(equal(["jane", "rick"]))
            }
            
            it("ends loading jane") {
                let user = UserModel()
                user.username = "jane"
                
                store.dispatch(UserProfileActionEndLoading(username: "jane", user: user))
                expect(store.state.loadingUsers).to(equal(["rick"]))
                expect(store.state.users).to(containElementSatisfying({ $0.username == "john" }))
                expect(store.state.users).to(containElementSatisfying({ $0.username == "jane" }))
            }
            
            it("ends loading rick") {
                let user = UserModel()
                user.username = "rick"
                
                store.dispatch(UserProfileActionEndLoading(username: "rick", user: user))
                expect(store.state.loadingUsers).to(beEmpty())
                expect(store.state.users).to(containElementSatisfying({ $0.username == "jane" }))
                expect(store.state.users).to(containElementSatisfying({ $0.username == "rick" }))
            }
        }
        
        xdescribe("action creaters") {
            let store = Store<AppState>(
                reducer: AppReducer(),
                state: nil)
            
            it("loads user") {
                store.dispatch(loadUserProfile(username: "octocat"))
                expect(store.state.userProfileState.loadingUsers).to(contain("octocat"))
                expect(store.state.userProfileState.loadingUsers).toEventuallyNot(contain("octocat"))
                expect(store.state.userProfileState.users).to(containElementSatisfying({ $0.username == "octocat" }))
            }
            
            it("doesn't loads user when cached") {
                store.dispatch(loadUserProfile(username: "octocat"))
                expect(store.state.userProfileState.loadingUsers).to(beEmpty())
            }
        }
    }
}
