//
//  Room.swift
//  mEatUp
//
//  Created by Paweł Knuth on 11.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import CloudKit

class Room: CloudKitObject, Equatable {
    static let entityName = "Room"
    
    var title: String?
    var accessType: AccessType?
    var restaurant: Restaurant?
    var maxCount: Int?
    var date: NSDate?
    var owner: User?
    var didEnd: Bool? = false
    
    var recordID: CKRecordID?
    
    var eventOccured: Bool {
        guard let date = date else {
            return true
        }
        
        return date.isLessThanDate(NSDate())
    }

    init(title: String, accessType: AccessType, restaurant: Restaurant, maxCount: Int, date: NSDate, owner: User) {
        self.title = title
        self.accessType = accessType
        self.restaurant = restaurant
        self.maxCount = maxCount
        self.date = date
        self.owner = owner
    }
    
    init() {
        owner = User()
        restaurant = Restaurant()
    }
    

}

func == (lhs: Room, rhs: Room) -> Bool {
    return lhs.recordID == rhs.recordID
}
