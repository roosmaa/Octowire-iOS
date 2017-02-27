//
//  UserProfileReducer.swift
//  Octowire
//
//  Created by Mart Roosmaa on 27/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import Foundation
import ReSwift

struct UserProfileReducer: Reducer {
    private let cachedProfilesCapacity: Int
    
    init(cachedProfilesCapacity: Int = 20) {
        self.cachedProfilesCapacity = cachedProfilesCapacity
    }
    
    func handleAction(action: Action, state: UserProfileState?) -> UserProfileState {
        var state = state ?? UserProfileState()
        
        switch action {
        case let action as UserProfileActionBeginLoading:
            state.loadingUsers.append(action.username)
        
        case let action as UserProfileActionEndLoading:
            if let idx = state.loadingUsers.index(of: action.username) {
                state.loadingUsers.remove(at: idx)
            }
            
            if let user = action.user {
                while state.users.count + 1 > cachedProfilesCapacity {
                    _ = state.users.popLast()
                }
                state.users.insert(user, at: 0)
            }
            
        default:
            break
        }
        
        return state
    }
}
