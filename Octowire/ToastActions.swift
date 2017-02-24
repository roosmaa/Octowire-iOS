//
//  ToastActions.swift
//  Octowire
//
//  Created by Mart Roosmaa on 24/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRecorder

let toastActionTypeMap: TypeMap = [
    ToastActionShow.type: ToastActionShow.self,
    ToastActionHide.type: ToastActionHide.self,
    ToastsActionClear.type: ToastsActionClear.self]

struct ToastActionShow: StandardActionConvertible {
    static let type = "TOAST_ACTION_SHOW"
    
    let toast: ToastModel
    
    init(toast: ToastModel) {
        self.toast = toast
    }
    
    init(_ standardAction: StandardAction) {
        self.toast = ToastModel(
            id: standardAction.payload!["id"] as! UUID,
            type: standardAction.payload!["toastType"] as! ToastType,
            message: standardAction.payload!["message"] as! String)
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(
            type: ToastActionShow.type,
            payload: [
                "id": self.toast.id as AnyObject,
                "toastType": self.toast.type as AnyObject,
                "message": self.toast.message as AnyObject
            ],
            isTypedAction: true)
    }
}

struct ToastActionHide: StandardActionConvertible {
    static let type = "TOAST_ACTION_HIDE"
    
    let id: UUID
    init(toast: ToastModel) {
        self.id = toast.id
    }
    
    init(_ standardAction: StandardAction) {
        self.id = standardAction.payload!["id"] as! UUID
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(
            type: ToastActionHide.type,
            payload: [
                "id": self.id as AnyObject,
                ],
            isTypedAction: true)
    }
}

struct ToastsActionClear: StandardActionConvertible {
    static let type = "TOAST_ACTION_CLEAR"
    
    init() {}
    
    init(_ standardAction: StandardAction) {}
    
    func toStandardAction() -> StandardAction {
        return StandardAction(
            type: ToastsActionClear.type,
            payload: nil,
            isTypedAction: true)
    }
}

func showToast(type: ToastType, message: String, duration: Double = 5.0) -> Store<AppState>.ActionCreator {
    let toast = ToastModel(type: type, message: message)
    
    return { state, store in
        store.dispatch(ToastActionShow(toast: toast))
        
        // Hide the notification after requested duration has passed
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            store.dispatch(ToastActionHide(toast: toast))
        }
        
        return nil
    }
}
