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
    var purposeHandler: ((RoomViewPurpose) -> Void)?
    var users = [User]()
    var room: Room?
    
    let cloudKitHelper = CloudKitHelper()
    var userRecordID: CKRecordID?
    
    var userInRoom: UserInRoom?
    
    init(userRecordID: CKRecordID, room: Room) {
        self.userRecordID = userRecordID
        self.room = room
    }
    
    func loadUsers() {
        self.users.removeAll()
        if let roomRecordID = room?.recordID {
            cloudKitHelper.loadUsersInRoomRecordWithRoomId(roomRecordID, completionHandler: { [weak self] user in
                self?.users.append(user)
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
