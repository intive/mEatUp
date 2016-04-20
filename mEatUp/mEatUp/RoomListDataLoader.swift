//
//  RoomDataLoader.swift
//  mEatUp
//
//  Created by Paweł Knuth on 18.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import CloudKit

class RoomListDataLoader {
    var cloudKitHelper: CloudKitHelper?
    
    var myRoom: [Room] = []
    var joinedRooms: [Room] = []
    var invitedRooms: [Room] = []
    var publicRooms: [Room] = []
    
    var currentRoomList: [Room] = []
    
    var completionHandler: (() -> Void)?
        
    var userRecordID: CKRecordID?

    init() {
        cloudKitHelper = CloudKitHelper()
    }
    
    func loadUserRecordFromCloudKit() {
        // testfbid is fbid placeholder and will be replaced by stored value
        cloudKitHelper?.loadUserRecordWithFbId("testfbid", completionHandler: {
            userRecord in
            if let userRecordID = userRecord.recordID {
                self.userRecordID = userRecordID
                self.loadRoomsForRoomList(userRecordID)
            }
        }, errorHandler: nil)
    }
    
    func loadRoomsForRoomList(userRecordID: CKRecordID) {
        cloudKitHelper?.loadPublicRoomRecords({
            room in
                self.publicRooms.append(room)
                self.completionHandler?()
        }, errorHandler: nil)
        
        
        cloudKitHelper?.loadInvitedRoomRecords(userRecordID, completionHandler: {
            room in
                if let room = room {
                    self.invitedRooms.append(room)
                    self.completionHandler?()
                }
        }, errorHandler: nil)
        
        
        cloudKitHelper?.loadUsersInRoomRecordWithUserId(userRecordID, completionHandler: {
            userRoom in
                if let userRoom = userRoom {
                    self.joinedRooms.append(userRoom)
                    self.completionHandler?()
                }
        }, errorHandler: nil)
        
        
        cloudKitHelper?.loadUserRoomRecord(userRecordID, completionHandler: {
            room in
                if let room = room {
                    self.myRoom.append(room)
                    self.completionHandler?()
                }
        }, errorHandler: nil)
    }
    
    func loadCurrentRoomList(dataScope: RoomDataScopes, filter: ((Room) -> Bool)?) {
        
        switch dataScope {
        case .Joined:
            if let filter = filter {
                currentRoomList = joinedRooms.filter({filter($0)})
            } else {
                currentRoomList = joinedRooms
            }
        case .Invited:
            if let filter = filter {
                currentRoomList = invitedRooms.filter({filter($0)})
            } else {
                currentRoomList = invitedRooms
            }
        case .MyRoom:
            if let filter = filter {
                currentRoomList = myRoom.filter({filter($0)})
            } else {
                currentRoomList = myRoom
            }
        case .Public:
            if let filter = filter {
                currentRoomList = publicRooms.filter({filter($0)})
            } else {
                currentRoomList = publicRooms
            }
        }
    }
}
