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
    
    func deleteSubscriptions() {
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
    
    func createUpdateRoomSubscription() {
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
    
    
    func createDeleteRoomSubscription() {
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
    
    func createCreateRoomSubscription() {
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
    
    func createCreateUserInRoomSubscription() {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        
        let subscription = CKSubscription(recordType: UserInRoom.entityName, predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = ["userRecordID", "roomRecordID", "confirmationStatus"]
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
    
    func createDeleteUserInRoomSubscription() {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        
        let subscription = CKSubscription(recordType: UserInRoom.entityName, predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordDeletion)
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = ["userRecordID", "roomRecordID", "confirmationStatus"]
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
    
    func createUpdateUserInRoomSubscription() {
        let predicate = NSPredicate(format: "confirmationStatus == 2")
        
        let subscription = CKSubscription(recordType: UserInRoom.entityName, predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordUpdate)
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = ["userRecordID", "roomRecordID", "confirmationStatus"]
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
