//
//  Restaurant.swift
//  mEatUp
//
//  Created by Paweł Knuth on 11.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import CloudKit

class Restaurant: CloudKitObject {
    static let entityName = "Restaurant"
    
    var restaurantID: Int?
    var name: String?
    var address: String?
    
    var recordID: CKRecordID?
    
    init(restaurantID: Int, name: String, address: String) {
        self.name = name
        self.address = address
    }
    
    convenience init() {
        self.init()
    }
}