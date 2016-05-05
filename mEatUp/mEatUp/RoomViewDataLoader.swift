//
//  RoomViewDataLoader.swift
//  mEatUp
//
//  Created by Paweł Knuth on 22.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import CloudKit

class RoomViewDataLoader {
    var refreshHandler: (() -> Void)?
    var dismissHandler: (() -> Void)?
    var purposeHandler: ((RoomViewPurpose) -> Void)?
    var users = [UserWithStatus]()
    var room: Room?
    
    let cloudKitHelper = CloudKitHelper()
    var userRecordID: CKRecordID?
    
    var userInRoom: UserInRoom?
    
    init(userRecordID: CKRecordID, room: Room) {
        self.userRecordID = userRecordID
        self.room = room
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(roomDeletedNotification), name: "roomDeleted", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userInRoomAddedNotification), name: "userInRoomAdded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userInRoomRemovedNotification), name: "userInRoomRemoved", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userInRoomUpdatedNotification), name: "userInRoomUpdated", object: nil)
    }
    
    @objc func userInRoomUpdatedNotification(aNotification: NSNotification) {
        if let userInRoomRecordID = aNotification.object as? CKRecordID {
            cloudKitHelper.loadUsersInRoomRecord(userInRoomRecordID, completionHandler: {
                userInRoom in
                if self.room == userInRoom.room, let user = userInRoom.user, let status = userInRoom.confirmationStatus {
                    self.confirmUserInRoom(&self.users, userWithStatus: UserWithStatus(user: user, status: status))
                    self.refreshHandler?()
                }
            }, errorHandler: nil)
        }
    }
    
    func confirmUserInRoom(inout array: [UserWithStatus], userWithStatus: UserWithStatus) {
        if let index = array.findIndex(userWithStatus) {
            array.removeAtIndex(index)
            array.append(userWithStatus)
        }
    }
    
    @objc func roomDeletedNotification(aNotification: NSNotification) {
        if let roomRecordID = aNotification.object as? CKRecordID {
            if roomRecordID == room?.recordID {
                dismissHandler?()
            }
        }
    }
    
    @objc func userInRoomAddedNotification(aNotification: NSNotification) {
        if let userInRoomRecordID = aNotification.object as? CKRecordID {
            cloudKitHelper.loadUsersInRoomRecord(userInRoomRecordID, completionHandler: {
                userInRoom in
                    if self.room == userInRoom.room, let user = userInRoom.user, let status = userInRoom.confirmationStatus {
                        self.users.append(UserWithStatus(user: user, status: status))
                        self.refreshHandler?()
                    }
            }, errorHandler: nil)
        }
    }

    @objc func userInRoomRemovedNotification(aNotification: NSNotification) {
        if let queryNotification = aNotification.object as? CKQueryNotification {
            if room?.recordID?.recordName == queryNotification.recordFields?["roomRecordID"] as? String {
                if let userRecordName = queryNotification.recordFields?["userRecordID"] as? String {
                    if userRecordName == userRecordID?.recordName {
                        //Alert - kicked from room
                        dismissHandler?()
                    } else {
                        self.users = self.users.filter({
                            guard let user = $0.user else {
                                return true
                            }
                            return filterRemovedUser(user, userRecordName: userRecordName)
                        })
                        refreshHandler?()
                    }
                }
            }
        }
    }
    
    func filterRemovedUser(user: User, userRecordName: String) -> Bool {
        if let recordName = user.recordID?.recordName {
            return !(recordName == userRecordName)
        }
        return false
    }
    
    func loadUsers() {
        self.users.removeAll()
        if let roomRecordID = room?.recordID {
            cloudKitHelper.loadUsersInRoomRecordWithRoomId(roomRecordID, completionHandler: { [weak self] userWithStatus in
                self?.users.append(userWithStatus)
                self?.refreshHandler?()
            }, errorHandler: nil)
        }
    }
    
    func determineViewPurpose() {
        if let userRecordID = userRecordID, roomRecordID = room?.recordID {
            cloudKitHelper.checkIfUserInRoom(roomRecordID, userRecordID: userRecordID, completionHandler: {
                userInRoom in
                self.userInRoom = userInRoom
                
                if userInRoom != nil {
                    if self.room?.owner?.recordID == userRecordID {
                        self.purposeHandler?(RoomViewPurpose.Owner)
                    } else {
                        self.purposeHandler?(RoomViewPurpose.Participant)
                    }
                } else {
                    self.purposeHandler?(RoomViewPurpose.User)
                }

                self.loadUsers()
            }, errorHandler: nil)
        }
    }
    
    func ableToJoin(completionBlock: ((Bool) -> Void)?) {
        guard let roomRecordID = room?.recordID else {
            return
        }
        
        return cloudKitHelper.usersInRoomRecordWithRoomIdCount(roomRecordID, completionHandler: {
            userCount in
                completionBlock?(self.room?.maxCount > userCount ? true: false)
        }, errorHandler: nil)
    }
    
    func leaveRoom(completionBlock: (() -> Void)?) {
        guard let userInRoom = self.userInRoom else {
            return
        }
        cloudKitHelper.deleteRecord(userInRoom, completionHandler: {
            self.purposeHandler?(RoomViewPurpose.User)
            self.loadUsers()
            self.userInRoom = nil
            
            completionBlock?()
        }, errorHandler: nil)
    }
    
    func deleteUser(userRow: Int, roomRecordID: CKRecordID) {
        if let userRecordID = users[userRow].user?.recordID {
            cloudKitHelper.deleteUserInRoomRecord(userRecordID, roomRecordID: roomRecordID, completionHandler: {
                self.purposeHandler?(RoomViewPurpose.Owner)
                self.loadUsers()
                } , errorHandler: nil)
        }
    }
    
    func joinRoom(completionBlock: (() -> Void)?) {
        if let userRecordID = userRecordID, let roomRecordID = room?.recordID where userInRoom == nil  {
            ableToJoin({
                isAble in
                if isAble {
                    self.userInRoom = UserInRoom(userRecordID: userRecordID, roomRecordID: roomRecordID, confirmationStatus: ConfirmationStatus.Accepted)
                    guard let userInRoom = self.userInRoom else {
                        return
                    }
                    
                    self.cloudKitHelper.saveUserInRoomRecord(userInRoom, completionHandler: {
                        self.purposeHandler?(RoomViewPurpose.Participant)
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC))),
                            dispatch_get_main_queue(), {
                                self.loadUsers()
                                completionBlock?()
                        })
                    }, errorHandler: nil)
                } else {
                    //ALERT! - Room is full
                }
            })
        } else {
            //ALERT! - User already in room
        }
    }
    
    func endRoom(completionHandler: (() -> Void)?, errorHandler: (() -> Void)?) {
        guard let room = room else {
            errorHandler?()
            return
        }
        
        room.didEnd = true
        
        cloudKitHelper.editRoomRecord(room, completionHandler: {
            completionHandler?()
            }, errorHandler: {
                error in
                    errorHandler?()
        })
    }
    
    func disbandRoom(completionHandler: (() -> Void)?, errorHandler: (() -> Void)?) {
        guard let room = room else {
            errorHandler?()
            return
        }
        
        cloudKitHelper.deleteRecord(room, completionHandler: {
            completionHandler?()
            }, errorHandler: {
                error in
                    errorHandler?()
        })
    }
}
