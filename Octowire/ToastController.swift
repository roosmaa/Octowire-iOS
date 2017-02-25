//
//  ToastController.swift
//  Octowire
//
//  Created by Mart Roosmaa on 25/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import ReSwift
import UIKit
import RMessage

class ToastController: NSObject {
    fileprivate weak var parentViewController: UIViewController?
    fileprivate var toastViews: [RMessageView] = []
    
    init(viewController: UIViewController) {
        self.parentViewController = viewController
    }
}

extension ToastController: StoreSubscriber {
    private func createViewForToast(toast: ToastModel) -> RMessageView? {
        guard let viewController = self.parentViewController else {
            return nil
        }
        
        let messageType: RMessageType
        let messageTitle: String
        
        switch toast.type {
        case .error:
            messageType = .error
            messageTitle = "Something failed :("
            
        case .info:
            messageType = .normal
            messageTitle = "This just in!"
        }
        
        let view = RMessageView(
            delegate: self,
            title: messageTitle,
            subtitle: toast.message,
            iconImage: nil,
            type: messageType,
            customTypeName: nil,
            duration: CGFloat(RMessageDuration.endless.rawValue),
            in: viewController,
            callback: nil,
            buttonTitle: nil,
            buttonCallback: nil,
            at: .top,
            canBeDismissedByUser: true)
        view?.toast = toast
        return view
    }
    
    func newState(state: AppState) {
        let toastState = state.toastState
        
        var visibleToastIds: [UUID] = []
        var viewsToDismiss: [RMessageView] = []
        var viewsToKeep: [RMessageView] = []
        
        for v in self.toastViews {
            guard let toastId = v.toast?.id else {
                viewsToDismiss.append(v)
                continue
            }
            
            let isVisible = toastState.visibleToasts.contains(where: { $0.id == toastId })
            if isVisible {
                viewsToKeep.append(v)
                visibleToastIds.append(toastId)
            } else {
                viewsToDismiss.append(v)
            }
        }
        
        // Dismiss old toast messages
        for v in viewsToDismiss {
            v.dismiss(completion: nil)
        }
        self.toastViews = viewsToKeep
        
        // Show new toast messages
        let newToasts = toastState.visibleToasts.filter { toastModel in
            return !visibleToastIds.contains(toastModel.id)
        }
        for toastModel in newToasts {
            guard let v = createViewForToast(toast: toastModel) else {
                continue
            }
            self.toastViews.append(v)
            v.present()
        }
    }
}

extension ToastController: RMessageViewProtocol {
    func messageViewDidPresent(_ messageView: RMessageView!) {
    }
    
    func messageViewDidDismiss(_ messageView: RMessageView!) {
    }
    
    func customVerticalOffset(for messageView: RMessageView!) -> CGFloat {
        return 0
    }
    
    func windowRemoved(forEndlessDurationMessageView messageView: RMessageView!) {
    }
    
    func didSwipe(toDismiss messageView: RMessageView!) {
        guard let toast = messageView.toast else {
            return
        }
        
        mainStore.dispatch(ToastActionHide(toast: toast))
    }
    
    func didTap(_ messageView: RMessageView!) {
        guard let toast = messageView.toast else {
            return
        }
        
        mainStore.dispatch(ToastActionHide(toast: toast))
    }
}

// Declare a global var to produce a unique address as the assoc object handle
private var RMessageView_ToastId_AssociatedObjectHandle: UInt8 = 0

extension RMessageView {
    var toast: ToastModel? {
        get {
            return objc_getAssociatedObject(self, &RMessageView_ToastId_AssociatedObjectHandle) as? ToastModel
        }
        set {
            objc_setAssociatedObject(self, &RMessageView_ToastId_AssociatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
