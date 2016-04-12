//
//  CloudKitObject.swift
//  mEatUp
//
//  Created by Paweł Knuth on 11.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudKitObject {
    var recordID: CKRecordID? { get set }
}
