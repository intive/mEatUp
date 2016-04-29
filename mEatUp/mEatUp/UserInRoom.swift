//
//  UserInRoom.swift
//  mEatUp
//
//  Created by Paweł Knuth on 11.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import CloudKit

class UserInRoom: CloudKitObject {
    static let entityName = "UserInRoom"
    
    var user: User?
    var room: Room?
    var confirmationStatus: ConfirmationStatus?
    
    var recordID: CKRecordID?
    
    init(user: User, room: Room, confirmationStatus: ConfirmationStatus) {
        self.user = user
        self.room = room
        self.confirmationStatus = confirmationStatus
    }
    
    init(userRecordID: CKRecordID, roomRecordID: CKRecordID, confirmationStatus: ConfirmationStatus) {
        let user = User()
        user.recordID = userRecordID
        self.user = user
        
        let room = Room()
        room.recordID = roomRecordID
        self.room = room
        
        self.confirmationStatus = confirmationStatus
    }
    
    init() {
    }
    
    func acceptInvite(cloudKitHelper: CloudKitHelper, completionHandler: (() -> Void)?, errorHandler: ((NSError?) -> Void)?) {
        self.confirmationStatus = .Accepted
        cloudKitHelper.saveUserInRoomRecord(self, completionHandler: completionHandler, errorHandler: errorHandler)
    }
}

func == (lhs: User, rhs: User) -> Bool {
    return lhs.recordID == rhs.recordID
}
