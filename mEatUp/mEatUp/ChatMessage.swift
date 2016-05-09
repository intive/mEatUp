//
//  ChatMessage.swift
//  mEatUp
//
//  Created by Paweł Knuth on 05.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import CloudKit

class ChatMessage: CloudKitObject {
    static var entityName = "ChatMessage"
    
    var roomRecordID: CKRecordID?
    var date: NSDate?
    var message: String?
    var userRecordID: CKRecordID?
    
    var user: User?
    
    var recordID: CKRecordID?
    
    init(roomRecordID: CKRecordID, userRecordID: CKRecordID, message: String) {
        self.roomRecordID = roomRecordID
        self.date = NSDate()
        self.userRecordID = userRecordID
        self.message = message
    }
    
    init() {
    }
    
}
