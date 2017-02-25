//
//  ToastModel.swift
//  Octowire
//
//  Created by Mart Roosmaa on 24/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import Foundation

enum ToastType {
    case error
    case info
}

/// ToastModel represents a temporary error/info message
struct ToastModel {
    let id: UUID
    let type: ToastType
    let message: String
    
    init(type: ToastType, message: String) {
        self.id = UUID()
        self.type = type
        self.message = message
    }
    
    init(id: UUID, type: ToastType, message: String) {
        self.id = id
        self.type = type
        self.message = message
    }
}

extension ToastModel: Equatable {
    static func ==(lhs: ToastModel, rhs: ToastModel) -> Bool {
        return lhs.id == rhs.id
            && lhs.type == rhs.type
            && lhs.message == rhs.message
    }
}
