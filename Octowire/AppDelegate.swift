//
//  AppDelegate.swift
//  Octowire
//
//  Created by Mart Roosmaa on 24/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import UIKit
import ReSwift
import ReSwiftRecorder
import RxSwift

let mainStore: Store<AppState> = createStore(
    reducer: AppReducer(),
    state: nil,
    typeMaps: [
        userProfileActionTypeMap,
        eventsBrowserActionTypeMap,
        navigationActionTypeMap,
        toastActionTypeMap
    ],
    middleware: [])

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let vc = NavigationController()
        
        mainStore.dispatch { state, store in
            if state.navigationState.stack.isEmpty {
                return NavigationActionStackReplace(
                    routes: [.events],
                    animated: false)
            } else {
                return nil
            }
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
        if let recordingStore = mainStore as? RecordingMainStore<AppState> {
            recordingStore.rewindControlYOffset = 150
            recordingStore.window = window
        }
        
        // Setup automatic event polling
        _ = Observable<Int>.timer(0, period: 2.05, scheduler: MainScheduler.instance)
            .subscribe({ _ in mainStore.dispatch(loadNextEvent()) })
        
        return true
    }
}

private func createStore<State>(reducer: AnyReducer,
                         state: State?,
                         typeMaps: [TypeMap],
                         middleware: [Middleware]) -> Store<State> {
    let env = ProcessInfo.processInfo.environment
    
    if env["ENABLE_TIME_TRAVEL"] != nil {
        return RecordingMainStore<State>(
            reducer: reducer,
            state: state,
            typeMaps: typeMaps,
            recording: "recording.json",
            middleware: middleware)
    } else {
        return Store<State>(reducer: reducer,
                            state: state,
                            middleware: middleware)
    }
}

