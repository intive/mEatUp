//
//  User.swift
//  mEatUp
//
//  Created by Paweł Knuth on 11.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import CloudKit

class User: CloudKitObject, Equatable {
    static let entityName = "User"

    var fbID: String?
    var name: String?
    var surname: String?
    var photo: String?
    
    var username: String {
        get {
            if let name = name, surname = surname {
                return "\(name) \(surname)"
            }
            return "Unknown"
        }
    }
    
    var recordID: CKRecordID?
    
    init(fbID: String, name: String, surname: String, photo: String) {
        self.fbID = fbID
        self.name = name
        self.surname = surname
        self.photo = photo
    }
    
    init() {
    }
}

func == (lhs: User, rhs: User) -> Bool {
    return lhs.recordID == rhs.recordID
}
