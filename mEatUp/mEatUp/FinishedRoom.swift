//
//  FinishedRoom.swift
//  mEatUp
//
//  Created by Maciej Plewko on 14.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import CoreData

@objc(FinishedRoom)
class FinishedRoom: NSManagedObject {

    class func entityName () -> String {
        return "FinishedRoom"
    }
    
}
