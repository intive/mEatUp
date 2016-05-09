//
//  AppDelegate.swift
//  mEatUp
//
//  Created by Maciej Plewko on 08.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import FBSDKLoginKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let cloudKitHelper = CloudKitHelper()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        application.applicationIconBadgeNumber = 0
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if let pushInfo = userInfo as? [String: NSObject] {
            let queryNotification = CKQueryNotification(fromRemoteNotificationDictionary: pushInfo)
            
            switch queryNotification.queryNotificationReason {
            case .RecordCreated:
                if let _ = queryNotification.recordFields?["message"] {
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "chatMessageAdded", object: queryNotification.recordID))
                } else if let _ = queryNotification.recordFields?["confirmationStatus"] {
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "userInRoomAdded", object: queryNotification.recordID))
                } else {
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "roomAdded", object: queryNotification.recordID))
                }
            case .RecordDeleted:
                if let _ = queryNotification.recordFields?["confirmationStatus"] {
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "userInRoomRemoved", object: queryNotification))
                } else {
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "roomDeleted", object: queryNotification.recordID))
                }
            case .RecordUpdated:
                if let _ = queryNotification.recordFields?["confirmationStatus"] {
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "userInRoomUpdated", object: queryNotification))
                } else {
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "roomUpdated", object: queryNotification.recordID))
                }
            }
        }
        return
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        // Reset incompatible store status in UserSettings
        UserSettings().incompatibleStoreDetection = false
    }

    func applicationWillTerminate(application: UIApplication) {
        CoreDataController.sharedInstance.saveContext()
    }
}
