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
    var dismissHandler: ((String) -> Void)?
    var purposeHandler: ((RoomViewPurpose) -> Void)?
    var users = [UserWithStatus]()
    var room: Room?
    
    let cloudKitHelper = CloudKitHelper()
    var userRecordID: CKRecordID?
    
    var userInRoom: UserInRoom?
    
    init(userRecordID: CKRecordID, room: Room) {
        self.userRecordID = userRecordID
        self.room = room
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(roomUpdatedNotification), name: "roomUpdated", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(roomDeletedNotification), name: "roomDeleted", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userInRoomAddedNotification), name: "userInRoomAdded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userInRoomRemovedNotification), name: "userInRoomRemoved", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userInRoomUpdatedNotification), name: "userInRoomUpdated", object: nil)
    }
    
    func removeNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc func roomUpdatedNotification(aNotification: NSNotification) {
        if let roomRecordID = aNotification.object as? CKRecordID {
            if roomRecordID == room?.recordID {
                cloudKitHelper.loadRoomRecord(roomRecordID, completionHandler: {
                    room in
                    guard let didEnd = room.didEnd, title = room.title else {
                        return
                    }
                    if didEnd {
                        let message = "A room with name \(title) has ended. Please visit settlements tab to ender balance."
                        self.dismissHandler?(message)
                    }
                }, errorHandler: nil)
            }
        }
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
                let message = "A room that you were in was removed"
                dismissHandler?(message)
                AlertCreator.singleActionAlert("Info", message: message, actionTitle: "OK", actionHandler: nil)
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
                        let message = "You have been kicked out of a room"
                        dismissHandler?(message)
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
                
                if userInRoom != nil && userInRoom?.confirmationStatus == .Accepted {
                    if self.room?.owner?.recordID == userRecordID {
                        self.purposeHandler?(RoomViewPurpose.Owner)
                    } else {
                        self.purposeHandler?(RoomViewPurpose.Participant)
                    }
                } else {
                    self.purposeHandler?(RoomViewPurpose.User)
                }
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
            self.userInRoom = nil
            self.loadUsers()
            
            completionBlock?()
        }, errorHandler: nil)
    }
    
    func deleteUser(userRow: Int, roomRecordID: CKRecordID) {
        if let userRecordID = users[userRow].user?.recordID {
            let userWithStatus = users[userRow]
            self.users.removeAtIndex(userRow)
            self.refreshHandler?()
            cloudKitHelper.deleteUserInRoomRecord(userRecordID, roomRecordID: roomRecordID, completionHandler: nil, errorHandler: {
                error in
                self.users.append(userWithStatus)
                self.refreshHandler?()
                AlertCreator.singleActionAlert("Error", message: "Could not remove user from room.", actionTitle: "OK", actionHandler: nil)
            })
        }
    }
    
    func joinRoom(completionBlock: (() -> Void)?) {
        if let userRecordID = userRecordID, let roomRecordID = room?.recordID where (userInRoom == nil || userInRoom?.confirmationStatus == .Invited) {
            ableToJoin({
                isAble in
                if isAble {
                    if let userInRoom = self.userInRoom {
                        userInRoom.confirmationStatus = .Accepted
                        self.cloudKitHelper.editUserInRoomRecord(userInRoom, completionHandler: {
                            self.loadUsers()
                            self.purposeHandler?(RoomViewPurpose.Participant)
                        }, errorHandler: nil)
                    } else {
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
                    }
                } else {
                    let message = "This room is currently full. You can not join it."
                    AlertCreator.singleActionAlert("Info", message: message, actionTitle: "OK", actionHandler: nil)
                }
            })
        } else {
            let message = "You have already joined this room."
            AlertCreator.singleActionAlert("Warning", message: message, actionTitle: "OK", actionHandler: nil)
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
