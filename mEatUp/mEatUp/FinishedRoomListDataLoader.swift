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
    let userSettings = UserSettings()
    
    var userRecordID: CKRecordID?
    
    var completionHandler: (() -> Void)?
    
    init() {
        cloudKitHelper = CloudKitHelper()
    }
    
    func loadUserRecordFromCloudKit() {
        if let fbID = userSettings.facebookID() {
            cloudKitHelper?.loadUserRecordWithFbId(fbID, completionHandler: {
                userRecord in
                if let userRecordID = userRecord.recordID {
                    self.userRecordID = userRecordID
                    self.loadFinishedRoomList(userRecordID)
                }
                }, errorHandler: nil)
        }
    }
    
    func loadFinishedRoomList(userRecordID: CKRecordID) {
        cloudKitHelper?.loadUserFinishedRoomRecords( userRecordID, completionHandler: {
            room in
            if let room = room {
                if let title = room.title, name = room.owner?.name, let surname = room.owner?.surname, let id = room.recordID, let restaurant = room.restaurant?.name, let date = room.date {
                    if let addedRoom = CoreDataController.sharedInstance.addFinishedRoom(id.recordName, title: title, owner: name + " " + surname, restaurant: restaurant, date: date) {
                        self.cloudKitHelper?.loadUsersInRoomRecordWithRoomId(id, completionHandler: { userWithStatus in
                            guard let user = userWithStatus.user else {
                                return
                            }
                            
                            if let userID = user.recordID, firstname = user.name, lastname = user.surname, pictureURL = user.photo where user.fbID != self.userSettings.facebookID() {
                                CoreDataController.sharedInstance.addUserToRoom(userID.recordName, firstname: firstname, lastname: lastname, pictureURL: pictureURL, room: addedRoom)
                            }
                        }, errorHandler: nil)
                    }
                }
                
            }
            self.completionHandler?()
            }, errorHandler: nil)
    }

}
