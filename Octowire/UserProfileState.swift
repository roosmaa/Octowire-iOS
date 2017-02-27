//
//  UserBrowserState.swift
//  Octowire
//
//  Created by Mart Roosmaa on 27/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import Foundation
import ReSwift

struct UserProfileState: StateType {
    var loadingUsers: [String] = []
    var users: [UserModel] = []
}
