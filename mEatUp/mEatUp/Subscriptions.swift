//
//  Subscriptions.swift
//  mEatUp
//
//  Created by Paweł Knuth on 26.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import CloudKit

class Subscriptions {
    var cloudKitHelper = CloudKitHelper()
    
    func deleteSubscription() {
        cloudKitHelper.publicDB.fetchAllSubscriptionsWithCompletionHandler({subscriptions, error in
            if error == nil {
                if let subscriptions = subscriptions {
                    for subscription in subscriptions {
                        self.cloudKitHelper.publicDB.deleteSubscriptionWithID(subscription.subscriptionID, completionHandler: { (str, error) -> Void in
                            if error != nil {
                                print(error!.localizedDescription)
                            }
                        })
                    }
                }
            }
        })
    }
    
    func createEditSubscription() {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        
        let subscription = CKSubscription(recordType: Room.entityName, predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordUpdate)
        
        let notificationInfo = CKNotificationInfo()
        
        notificationInfo.alertBody = "Room you were in has changed"
        notificationInfo.shouldBadge = false
        
        subscription.notificationInfo = notificationInfo
        
        cloudKitHelper.publicDB.saveSubscription(subscription, completionHandler: {
            returnRecord, error in
            if let error = error {
                print("Subscription faild \(error)")
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("Subscription succeed")
                })
            }
        })
    }
    
    
    func createDeleteSubscription() {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        
        let subscription = CKSubscription(recordType: Room.entityName, predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordDeletion)
        
        let notificationInfo = CKNotificationInfo()
        
        notificationInfo.alertBody = "Room you were in has been deleted"
        notificationInfo.shouldBadge = false
        
        subscription.notificationInfo = notificationInfo
        
        cloudKitHelper.publicDB.saveSubscription(subscription, completionHandler: {
            returnRecord, error in
            if let error = error {
                print("Subscription faild \(error)")
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("Subscription succeed")
                })
            }
        })
    }
    
    func createCreateSubscription() {
        let predicate = NSPredicate(format: "accessType == 2")
        
        let subscription = CKSubscription(recordType: Room.entityName, predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
        
        let notificationInfo = CKNotificationInfo()
        
        notificationInfo.shouldBadge = false
        
        subscription.notificationInfo = notificationInfo
        
        cloudKitHelper.publicDB.saveSubscription(subscription, completionHandler: {
            returnRecord, error in
            if let error = error {
                print("Subscription faild \(error)")
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("Subscription succeed")
                })
            }
        })
    }
}
