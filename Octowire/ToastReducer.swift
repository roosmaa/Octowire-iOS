//
//  ToastReducer.swift
//  Octowire
//
//  Created by Mart Roosmaa on 24/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import Foundation
import ReSwift

struct ToastReducer: Reducer {
    func handleAction(action: Action, state: ToastState?) -> ToastState {
        var state = state ?? ToastState()
        
        switch action {
        case let a as ToastActionShow:
            state.visibleToasts.append(a.toast)
            
        case let a as ToastActionHide:
            state.visibleToasts = state.visibleToasts.filter({ t in t.id != a.id })
            
        case _ as ToastsActionClear:
            state.visibleToasts = []
            
        default:
            break
        }
        
        return state
    }
}
