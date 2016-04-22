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
    
    func leaveRoom() {
        guard let userInRoom = self.userInRoom else {
            return
        }
        cloudKitHelper.deleteRecord(userInRoom, completionHandler: {
            self.purposeHandler?(RoomViewPurpose.User)
            self.loadUsers()
            self.userInRoom = nil
           
            }, errorHandler: nil)
    }
    
    func joinRoom() {
        if let userRecordID = userRecordID, let roomRecordID = room?.recordID {
            if userInRoom == nil {
                self.userInRoom = UserInRoom(userRecordID: userRecordID, roomRecordID: roomRecordID, confirmationStatus: ConfirmationStatus.Accepted)
                guard let userInRoom = self.userInRoom else {
                    return
                }
                
                self.cloudKitHelper.saveUserInRoomRecord(userInRoom, completionHandler: {
                    self.purposeHandler?(RoomViewPurpose.Participant)
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC))),
                        dispatch_get_main_queue(), {
                            self.loadUsers()
                    })
                }, errorHandler: nil)
            }
        }
    }
}
