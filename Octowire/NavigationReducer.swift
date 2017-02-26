//
//  NavigationReducer.swift
//  Octowire
//
//  Created by Mart Roosmaa on 24/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import Foundation
import ReSwift

struct NavigationReducer: Reducer {
    func handleAction(action: Action, state: NavigationState?) -> NavigationState {
        var state = state ?? NavigationState()
        
        switch action {
        case let a as NavigationActionStackPush:
            state.stack.append(a.route)
            if a.animated {
                state.animationCounter += 1
            } else {
                state.animationCounter = 0
            }
            
        case let a as NavigationActionStackPop:
            if state.stack.count > 1 {
                state.stack.remove(at: state.stack.count - 1)

                if a.animated {
                    state.animationCounter += 1
                } else {
                    state.animationCounter = 0
                }
            }
            
        case let a as NavigationActionStackReplace:
            state.stack = a.routes
            if a.animated {
                state.animationCounter += 1
            } else {
                state.animationCounter = 0
            }
            
        default:
            break
        }
        
        return state
    }
}
