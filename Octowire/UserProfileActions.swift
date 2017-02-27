//
//  UserProfileActions.swift
//  Octowire
//
//  Created by Mart Roosmaa on 27/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRecorder
import Alamofire
import AlamofireObjectMapper

let userProfileActionTypeMap: TypeMap = [
    UserProfileActionBeginLoading.type: UserProfileActionBeginLoading.self,
    UserProfileActionEndLoading.type: UserProfileActionEndLoading.self]

struct UserProfileActionBeginLoading: StandardActionConvertible {
    static let type = "USER_PROFILE_ACTION_BEGIN_LOADING"
    
    let username: String
    
    init(username: String) {
        self.username = username
    }
    
    init(_ standardAction: StandardAction) {
        self.username = standardAction.payload!["username"] as! String
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(
            type: UserProfileActionBeginLoading.type,
            payload: [
                "username": self.username as AnyObject],
            isTypedAction: true)
    }
}

struct UserProfileActionEndLoading: StandardActionConvertible {
    static let type = "USER_PROFILE_ACTION_END_LOADING"
    
    let username: String
    let user: UserModel?
    
    init(username: String, user: UserModel?) {
        self.username = username
        self.user = user
    }
    
    init(_ standardAction: StandardAction) {
        self.username = standardAction.payload!["username"] as! String
        self.user = decode(standardAction.payload!["user"])
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(
            type: UserProfileActionEndLoading.type,
            payload: [
                "username": self.username as AnyObject,
                "user": encode(self.user)],
            isTypedAction: true)
    }
}

func loadUserProfile(username: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        guard !state.userProfileState.loadingUsers.contains(username) else {
            return nil
        }
        
        guard !state.userProfileState.users.contains(where: { $0.username == username }) else {
            return nil
        }
        
        store.dispatch(UserProfileActionBeginLoading(username: username))
        
        Alamofire
            .request("https://api.github.com/users/\(username)",
                headers: ["Accept": "application/vnd.github.v3+json"])
            .responseObject(completionHandler: { (resp: DataResponse<UserModel>) in
                let user: UserModel?
                
                if let value = resp.result.value {
                    user = value
                } else {
                    user = nil
                    
                    print("Failed to get user from GitHub: \(resp.error)")
                    store.dispatch(showToast(type: .error, message: "Unable to connect to GitHub"))
                }
                
                store.dispatch(UserProfileActionEndLoading(username: username, user: user))
            })
        
        return nil
    }
}

private func encode(_ value: UserModel?) -> AnyObject {
    if let value = value {
        return value.toJSONString() as AnyObject
    } else {
        return "" as AnyObject
    }
}

private func decode(_ value: AnyObject?) -> UserModel? {
    let value = value as! String
    if value == "" {
        return nil
    } else {
        return UserModel(JSONString: value)!
    }
}
