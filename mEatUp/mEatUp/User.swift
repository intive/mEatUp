//
//  User.swift
//  mEatUp
//
//  Created by Paweł Knuth on 11.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import CloudKit

class User: CloudKitObject {
    static let entityName = "User"
    
    var fbID: String?
    var name: String?
    var surname: String?
    var photo: String?
    
    var recordID: CKRecordID?
    
    init(fbID: String, name: String, surname: String, photo: String) {
        self.fbID = fbID
        self.name = name
        self.surname = surname
        self.photo = photo
    }
    
    convenience init() {
        self.init()
    }
}
