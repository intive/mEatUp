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
            if let subscriptions = subscriptions where error == nil {
                for subscription in subscriptions {
                    self.cloudKitHelper.publicDB.deleteSubscriptionWithID(subscription.subscriptionID, completionHandler: { (str, error) -> Void in
                        if error != nil {
                            print(error!.localizedDescription)
                        }
                    })
                }
            }
        })
    }
    
    func createSubscription(predicate: NSPredicate, recordType: String, option: CKSubscriptionOptions, desiredKeys: [String]?) {
        let subscription = CKSubscription(recordType: recordType, predicate: predicate, options: option)
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = desiredKeys
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
    
    func createSubscriptions() {
        createUpdateRoomSubscription()
        createDeleteRoomSubscription()
        createCreateRoomSubscription()
        createCreateUserInRoomSubscription()
        createDeleteUserInRoomSubscription()
        createUpdateUserInRoomSubscription()
        createCreateChatMessageSubscription()
    }
    
    func createUpdateRoomSubscription() {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        
        createSubscription(predicate, recordType: Room.entityName, option: .FiresOnRecordUpdate, desiredKeys: nil)
    }
    
    func createDeleteRoomSubscription() {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        
        createSubscription(predicate, recordType: Room.entityName, option: .FiresOnRecordDeletion, desiredKeys: nil)
    }
    
    func createCreateRoomSubscription() {
        let predicate = NSPredicate(format: "accessType == 2")
        
        createSubscription(predicate, recordType: Room.entityName, option: .FiresOnRecordCreation, desiredKeys: nil)
    }
    
    func createCreateUserInRoomSubscription() {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        
        createSubscription(predicate, recordType: UserInRoom.entityName, option: .FiresOnRecordCreation, desiredKeys: ["userRecordID", "roomRecordID", "confirmationStatus"])
    }
    
    func createDeleteUserInRoomSubscription() {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        
        createSubscription(predicate, recordType: UserInRoom.entityName, option: .FiresOnRecordDeletion, desiredKeys: ["userRecordID", "roomRecordID", "confirmationStatus"])
    }
    
    func createUpdateUserInRoomSubscription() {
        let predicate = NSPredicate(format: "confirmationStatus == 2")
        
        createSubscription(predicate, recordType: UserInRoom.entityName, option: .FiresOnRecordUpdate, desiredKeys: ["userRecordID", "roomRecordID", "confirmationStatus"])
    }
    
    func createCreateChatMessageSubscription() {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        
        createSubscription(predicate, recordType: ChatMessage.entityName, option: .FiresOnRecordCreation, desiredKeys: ["message"])
    }
}
