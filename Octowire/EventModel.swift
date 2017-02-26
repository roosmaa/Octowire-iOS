//
//  EventModel.swift
//  Octowire
//
//  Created by Mart Roosmaa on 25/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import Foundation
import ObjectMapper

class EventModel: StaticMappable {
    var id: String!
    var type: String!
    var createdAt: Date?
    
    var repoId: Int64?
    var repoName: String?

    var actorId: Int64?
    var actorUsername: String?
    var actorAvatarUrl: String?
    
    static func objectForMapping(map: Map) -> BaseMappable? {
        guard let type: String = map["type"].value() else {
            return nil
        }
        
        switch type {
        case "CreateEvent": return CreateEventModel()
        case "ForkEvent": return ForkEventModel()
        case "WatchEvent": return WatchEventModel()
        case "PullRequestEvent": return PullRequestEventModel()
        default: return nil
        }
    }
    
    init() {
    }
    
    func mapping(map: Map) {
        self.id <- map["id"]
        self.type <- map["type"]
        self.createdAt <- (map["created_at"], ISO8601DateTransform())
        
        self.repoId <- map["repo.id"]
        self.repoName <- map["repo.name"]
        
        self.actorId <- map["actor.id"]
        self.actorUsername <- map["actor.login"]
        self.actorAvatarUrl <- map["actor.avatar_url"]
    }
}

class CreateEventModel: EventModel {
    enum RefType: String {
        case repository = "repository"
        case brand = "branch"
        case tag = "tag"
    }
    
    var refType: RefType?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        self.refType <- map["payload.ref_type"]
    }
}

class ForkEventModel: EventModel {
    var forkRepoName: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        self.forkRepoName <- map["payload.forkee.name"]
    }
}

class WatchEventModel: EventModel {
    override func mapping(map: Map) {
        super.mapping(map: map)
    }
}

class PullRequestEventModel: EventModel {
    enum ActionKind: String {
        case assigned = "assigned"
        case unassigned = "unassigned"
        case reviewRequested = "review_requested"
        case reviewRequestRemoved = "review_request_removed"
        case labeled = "labeled"
        case unlabeled = "unlabeled"
        case opened = "opened"
        case edited = "edited"
        case closed = "closed"
        case reopened = "reopened"
    }
    
    var action: ActionKind?
    var pullRequestNumber: Int64?

    override func mapping(map: Map) {
        super.mapping(map: map)
        
        self.action <- map["payload.action"]
        self.pullRequestNumber <- map["payload.number"]
    }
}
