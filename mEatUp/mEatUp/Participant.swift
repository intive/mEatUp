//
//  Participant.swift
//  mEatUp
//
//  Created by Maciej Plewko on 14.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import CoreData

@objc(Participant)
class Participant: NSManagedObject {

    class func entityName () -> String {
        return "Participant"
    }

}
