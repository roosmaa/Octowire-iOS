//
//  NavigationActions.swift
//  Octowire
//
//  Created by Mart Roosmaa on 24/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRecorder

let navigationActionTypeMap: TypeMap = [
    NavigationActionStackReplace.type: NavigationActionStackReplace.self,
    NavigationActionStackPush.type: NavigationActionStackPush.self,
    NavigationActionStackPop.type: NavigationActionStackPop.self]

struct NavigationActionStackReplace: StandardActionConvertible {
    static let type = "NAVIGATION_ACTION_STACK_REPLACE"
    
    let routes: [Route]
    let animated: Bool
    
    init(routes: [Route], animated: Bool = true) {
        self.routes = routes
        self.animated = animated
    }
    
    init(_ standardAction: StandardAction) {
        self.routes = decode(standardAction.payload!["routes"])
        self.animated = standardAction.payload!["animated"] as! Bool
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(
            type: NavigationActionStackReplace.type,
            payload: [
                "routes": encode(self.routes),
                "animated": self.animated as AnyObject],
            isTypedAction: true)
    }
}

struct NavigationActionStackPush: StandardActionConvertible {
    static let type = "NAVIGATION_ACTION_STACK_PUSH"
    
    let route: Route
    let animated: Bool
    
    init(route: Route, animated: Bool = true) {
        self.route = route
        self.animated = animated
    }
    
    init(_ standardAction: StandardAction) {
        self.route = decode(standardAction.payload!["route"])
        self.animated = standardAction.payload!["animated"] as! Bool
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(
            type: NavigationActionStackPush.type,
            payload: [
                "route": encode(self.route),
                "animated": self.animated as AnyObject],
            isTypedAction: true)
    }
}

struct NavigationActionStackPop: StandardActionConvertible {
    static let type = "NAVIGATION_ACTION_STACK_POP"
    
    let animated: Bool
    
    init(animated: Bool = true) {
        self.animated = animated
    }
    
    init(_ standardAction: StandardAction) {
        self.animated = standardAction.payload!["animated"] as! Bool
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(
            type: NavigationActionStackPop.type,
            payload: [
                "animated": self.animated as AnyObject],
            isTypedAction: true)
    }
}

private func encode(_ value: [Route]) -> AnyObject {
    return value.map({ $0.rawValue }) as AnyObject
}

private func encode(_ value: Route) -> AnyObject {
    return value.rawValue as AnyObject
}

private func decode(_ value: AnyObject?) -> Route {
    return Route(rawValue: value as! [String: String])!
}

private func decode(_ value: AnyObject?) -> [Route] {
    let r = value as! [[String: String]]
    return r.map({ Route(rawValue: $0)! })
}
