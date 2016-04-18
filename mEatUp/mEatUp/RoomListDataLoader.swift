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
    
    var myRoom: Room?
    var joinedRooms: [Room] = []
    var publicRooms: [Room] = []
    
    let sections = [SectionNames.MyRoom.rawValue, SectionNames.Joined.rawValue, SectionNames.Public.rawValue]
    
    var userRecordID: CKRecordID?

    init() {
        cloudKitHelper = CloudKitHelper()
    }
    
    func loadUserRecordFromCloudKit(completionHandler: (() -> Void)) {
        // testfbid is fbid placeholder and will be replaced by stored value
        cloudKitHelper?.loadUserRecordWithFbId("testfbid", completionHandler: {
            userRecord in
            if let userRecordID = userRecord.recordID {
                self.userRecordID = userRecordID
                self.loadRoomsForRoomList(userRecordID, completionHandler: completionHandler)
            }
            }, errorHandler: nil)
    }
    
    func loadRoomsForRoomList(userRecordID: CKRecordID, completionHandler: (() -> Void)) {
        cloudKitHelper?.loadPublicRoomRecords({
            room in
                self.publicRooms.append(room)
                self.filterRooms(completionHandler)
            
        }, errorHandler: nil)
        
        
        cloudKitHelper?.loadInvitedRoomRecords(userRecordID, completionHandler: {
            room in
            if let room = room {
                self.joinedRooms.append(room)
                self.filterRooms(completionHandler)
            }
        }, errorHandler: nil)
        
        
        cloudKitHelper?.loadUsersInRoomRecordWithUserId(userRecordID, completionHandler: {
            userRoom in
            if let userRoom = userRoom {
                self.joinedRooms.append(userRoom)
                self.filterRooms(completionHandler)
            }
        }, errorHandler: nil)
        
        
        cloudKitHelper?.loadUserRoomRecord(userRecordID, completionHandler: {
            room in
                self.myRoom = room
                self.filterRooms(completionHandler)
        }, errorHandler: nil)
    }
    
    func filterRooms(completionHandler: (() -> Void)) {
        if joinedRooms.count != 0 {
            for room in joinedRooms {
                self.publicRooms = publicRooms.filter({($0.recordID?.recordName != room.recordID?.recordName) || ($0.recordID?.recordName != myRoom?.recordID?.recordName)})
            }
        }
        self.joinedRooms = joinedRooms.filter({ $0.recordID?.recordName != myRoom?.recordID?.recordName })
        
        completionHandler()
    }
}