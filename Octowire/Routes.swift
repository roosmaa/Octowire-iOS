//
//  Routes.swift
//  Octowire
//
//  Created by Mart Roosmaa on 24/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import UIKit

private let RouteTypeKey = "$route"

private enum RouteType: String {
    case events = "EVENTS_ROUTE"
    case userProfile = "USER_PROFILE_ROUTE"
}

enum Route: RawRepresentable {
    case events
    case userProfile(username: String)
    
    init?(rawValue: [String: String]) {
        guard let rawType = rawValue[RouteTypeKey],
            let type = RouteType(rawValue: rawType) else {
                return nil
        }
        
        switch type {
        case .events: self = .events
        case .userProfile: self = .userProfile(username: rawValue["username"]!)
        }
    }
    
    func initViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        switch self {
        case .events:
            let vc = storyboard.instantiateViewController(withIdentifier: "EventsBrowser") as! EventsBrowserViewController
            vc.route = self
            return vc
            
        case .userProfile(username: let username):
            let vc = storyboard.instantiateViewController(withIdentifier: "UserProfile") as! UserProfileViewController
            vc.username = username
            vc.route = self
            return vc
        }
    }
    
    var rawValue: [String: String] {
        switch self {
        case .events:
            return [RouteTypeKey: RouteType.events.rawValue]
        case .userProfile(username: let username):
            return [RouteTypeKey: RouteType.userProfile.rawValue,
                    "username": username]
        }
    }
}

extension Route: Equatable {
    static func ==(lhs: Route, rhs: Route) -> Bool {
        switch lhs {
        case .events:
            if case .events = rhs {
                return true
            } else {
                return false
            }
        case .userProfile(username: let lhsUsername):
            if case .userProfile(username: let rhsUsername) = rhs {
                return lhsUsername == rhsUsername
            } else {
                return false
            }
        }
    }
}

// Declare a global var to produce a unique address as the assoc object handle
private var UIViewController_Route_AssociatedObjectHandle: UInt8 = 0

extension UIViewController {
    var route: Route? {
        get {
            return objc_getAssociatedObject(self, &UIViewController_Route_AssociatedObjectHandle) as? Route
        }
        set {
            objc_setAssociatedObject(self, &UIViewController_Route_AssociatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
