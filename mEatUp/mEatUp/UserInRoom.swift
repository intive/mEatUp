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
    var user: User?
    var room: Room?
    var confirmationStatus: ConfirmationStatus?
    
    var recordID: CKRecordID?
    
    init(user: User, room: Room, confirmationStatus: ConfirmationStatus) {
        self.user = user
        self.room = room
        self.confirmationStatus = confirmationStatus
    }
    
    convenience init() {
        self.init()
    }
    
    func acceptInvite(cloudKitHelper: CloudKitHelper) {
        self.confirmationStatus = .Accepted
        cloudKitHelper.saveUserInRoomRecord(self)
    }
}