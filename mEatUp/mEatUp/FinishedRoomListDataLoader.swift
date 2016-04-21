//
//  FinishedRoomListDataLoader.swift
//  mEatUp
//
//  Created by Maciej Plewko on 20.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import CloudKit

class FinishedRoomListDataLoader {
    var cloudKitHelper: CloudKitHelper?
    
    var userRecordID: CKRecordID?
    
    var completionHandler: (() -> Void)?
    
    init() {
        cloudKitHelper = CloudKitHelper()
    }
    
    func loadUserRecordFromCloudKit() {
        // testfbid is fbid placeholder and will be replaced by stored value
        cloudKitHelper?.loadUserRecordWithFbId("testfbid", completionHandler: {
            userRecord in
            if let userRecordID = userRecord.recordID {
                self.userRecordID = userRecordID
                self.loadFinishedRoomList(userRecordID)
            }
            }, errorHandler: nil)
    }
    
    func loadFinishedRoomList(userRecordID: CKRecordID) {
        cloudKitHelper?.loadPublicRoomRecords({
            room in
            if let title = room.title, name = room.owner?.name, let surname = room.owner?.surname, let id = room.recordID?.recordName, let restaurant = room.restaurant?.name, let date = room.date {
                CoreDataController.sharedInstance.addFinishedRoom(id, title: title, owner: name + " " + surname, restaurant: restaurant, date: date)
            }
            self.completionHandler?()
            }, errorHandler: nil)
    }

}
