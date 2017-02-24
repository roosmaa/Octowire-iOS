//
//  ToastSpec.swift
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

class ToastStateSpec: QuickSpec {
    override func spec() {
        describe("toast actions") {
            let store = Store<ToastState>(
                reducer: ToastReducer(),
                state: nil)
            
            let t1 = ToastModel(type: .Info, message: "Hello, world!")
            it("shows a toast") {
                store.dispatch(ToastActionShow(toast: t1))
                expect(store.state.visibleToasts).to(contain(t1))
            }
            
            let t2 = ToastModel(type: .Error, message: "Oh noes :(")
            it("shows multiple toasts") {
                store.dispatch(ToastActionShow(toast: t2))
                expect(store.state.visibleToasts).to(beginWith(t1))
                expect(store.state.visibleToasts).to(endWith(t2))
            }
            
            it("hides the first toast") {
                store.dispatch(ToastActionHide(toast: t1))
                expect(store.state.visibleToasts).notTo(contain(t1))
            }
            
            it("clears all of the visible toasts") {
                store.dispatch(ToastsActionClear())
                expect(store.state.visibleToasts).to(beEmpty())
            }
        }
        
        describe("toast functions") {
            let store = Store<AppState>(
                reducer: AppReducer(),
                state: nil)
            
            it("shows and hides the toast") {
                store.dispatch(showToast(type: .Info, message: "Howdy!", duration: 0.0001));
                expect(store.state.toastState.visibleToasts).to(haveCount(1))
                expect(store.state.toastState.visibleToasts).toEventually(beEmpty())
            }
        }
    }
}
