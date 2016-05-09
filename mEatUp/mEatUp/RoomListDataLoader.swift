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
    let userSettings = UserSettings()
    
    var myRoom: [Room] = []
    var joinedRooms: [Room] = []
    var invitedRooms: [Room] = []
    var publicRooms: [Room] = []
    
    var currentRoomList: [Room] {
        get {
            return loadCurrentRoomList(dataScope, filter: filter)
        }
    }
    
    var dataScope: RoomDataScopes = .Public
    var filter: ((Room) -> Bool)? = nil
    
    var completionHandler: (() -> Void)?
        
    var userRecordID: CKRecordID?

    init() {
        cloudKitHelper = CloudKitHelper()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(roomAddedNotification), name: "roomAdded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(roomDeletedNotification), name: "roomDeleted", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(roomUpdatedNotification), name: "roomUpdated", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userInRoomAddedNotification), name: "userInRoomAdded", object: nil)
    }
    
    @objc func userInRoomAddedNotification(aNotification: NSNotification) {
        if let userInRoomRecordID = aNotification.object as? CKRecordID {
            cloudKitHelper?.loadUsersInRoomRecord(userInRoomRecordID, completionHandler: {
                userInRoom in
                if self.userRecordID == userInRoom.user?.recordID {
                    let message = "You have been invited to a room. Check the 'Invited' section."
                    AlertCreator.singleActionAlert("Info", message: message, actionTitle: "OK", actionHandler: nil)
                }
            }, errorHandler: nil)
        }
    }
    
    @objc func roomUpdatedNotification(aNotification: NSNotification) {
        if let roomRecordID = aNotification.object as? CKRecordID {
            cloudKitHelper?.loadRoomRecord(roomRecordID, completionHandler: {
                room in
                    self.replaceRoomInArray(&self.publicRooms, room: room)
                    self.replaceRoomInArray(&self.joinedRooms, room: room)
                    self.replaceRoomInArray(&self.invitedRooms, room: room)
                    self.completionHandler?()
            }, errorHandler: nil)
            
            if let userRecordID = userRecordID {
                cloudKitHelper?.checkIfUserInRoom(roomRecordID, userRecordID: userRecordID, completionHandler: {
                    inRoom in
                    if inRoom != nil {
                        let message = "A room that you have joined has been modified."
                        AlertCreator.singleActionAlert("Info", message: message, actionTitle: "OK", actionHandler: nil)
                    }
                }, errorHandler: nil)
            }
        }
    }
    
    func replaceRoomInArray(inout array: [Room], room: Room) {
        if let index = array.findIndex(room) {
            array.removeAtIndex(index)
            array.append(room)
        }
    }
    
    @objc func roomAddedNotification(aNotification: NSNotification) {
        if let roomRecordID = aNotification.object as? CKRecordID {
            cloudKitHelper?.loadRoomRecord(roomRecordID, completionHandler: {
                room in
                    self.publicRooms.append(room)
                    self.completionHandler?()
            }, errorHandler: nil)
        }
    }
    
    @objc func roomDeletedNotification(aNotification: NSNotification) {
        if let roomRecordID = aNotification.object as? CKRecordID {
            self.publicRooms = self.publicRooms.filter({return filterRemovedRoom($0, roomRecordID: roomRecordID)})
            self.joinedRooms = self.joinedRooms.filter({return filterRemovedRoom($0, roomRecordID: roomRecordID)})
            self.invitedRooms = self.invitedRooms.filter({return filterRemovedRoom($0, roomRecordID: roomRecordID)})
            
            self.completionHandler?()
        }
    }
    
    func loadUserRecordFromCloudKit() {
        if let fbID = userSettings.facebookID() {
            cloudKitHelper?.loadUserRecordWithFbId(fbID, completionHandler: {
                userRecord in
                if let userRecordID = userRecord.recordID {
                    self.userRecordID = userRecordID
                    self.loadRoomsForRoomList(userRecordID)
                }
                }, errorHandler: nil)
        }
    }
    
    func filterRemovedRoom(room: Room, roomRecordID: CKRecordID) -> Bool {
        if let recordID = room.recordID {
            return !(recordID == roomRecordID)
        }
        return false
    }
    
    func loadRoomsForRoomList(userRecordID: CKRecordID) {
        myRoom.removeAll()
        joinedRooms.removeAll()
        invitedRooms.removeAll()
        publicRooms.removeAll()
        
        cloudKitHelper?.loadPublicRoomRecords({
            room in
            if !room.eventOccured {
                self.publicRooms.append(room)
                self.completionHandler?()
            }
        }, errorHandler: nil)
        
        
        cloudKitHelper?.loadInvitedRoomRecords(userRecordID, completionHandler: {
            room in
                if let room = room where !room.eventOccured {
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
    
    func loadCurrentRoomList(dataScope: RoomDataScopes, filter: ((Room) -> Bool)?) -> [Room] {
        switch dataScope {
        case .Joined:
            if let filter = filter {
                return joinedRooms.filter({filter($0)})
            } else {
                return joinedRooms
            }
        case .Invited:
            if let filter = filter {
                return invitedRooms.filter({filter($0)})
            } else {
                return invitedRooms
            }
        case .MyRoom:
            if let filter = filter {
                return myRoom.filter({filter($0)})
            } else {
                return myRoom
            }
        case .Public:
            if let filter = filter {
                return publicRooms.filter({filter($0)})
            } else {
                return publicRooms
            }
        }
    }
}
