//
//  FinishedRoom+CoreDataProperties.swift
//  mEatUp
//
//  Created by Maciej Plewko on 14.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FinishedRoom {

    @NSManaged var owner: String?
    @NSManaged var title: String
    @NSManaged var restaurant: String?
    @NSManaged var date: NSDate?
    @NSManaged var roomID: NSNumber
    @NSManaged var participants: NSSet?

}
