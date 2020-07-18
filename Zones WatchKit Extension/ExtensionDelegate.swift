//
//  ExtensionDelegate.swift
//  Zones WatchKit Extension
//
//  Created by Steph Ananth on 7/17/20.
//  Copyright © 2020 Steph K. Ananth. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        print("ExtensionDelegate.applicationDidFinishLaunching()")
        // Perform any final initialization of your application.
    }

    func applicationDidBecomeActive() {
        print("ExtensionDelegate.applicationDidBecomeActive()")
        // Restart any tasks that were paused (or not yet started) while the application was inactive.
        // If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        print("ExtensionDelegate.applicationWillResignActive()")
        // Sent when the application is about to move from active to inactive state.
        // This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
        // or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        print("ExtensionDelegate.handle(_ backgroundTasks: \(backgroundTasks))")
        // Sent when the system needs to launch the application in the background to process tasks.
        // Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                print("ExtensionDelegate.handle() > task: \(backgroundTask)")
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                print("ExtensionDelegate.handle() > task: \(snapshotTask)")
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true,
                                              estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                print("ExtensionDelegate.handle() > task: \(connectivityTask)")
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                print("ExtensionDelegate.handle() > task: \(urlSessionTask)")
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                print("ExtensionDelegate.handle() > task: \(relevantShortcutTask)")
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                print("ExtensionDelegate.handle() > task: \(intentDidRunTask)")
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                print("ExtensionDelegate.handle() > task: \(task) -> DEFAULT")
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}
