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
    static var entityName = "Restaurant"
    
    var name: String?
    var address: String?
    
    var recordID: CKRecordID?
    
    init(name: String, address: String) {
        self.name = name
        self.address = address
    }
    
    init() {
    }
}
