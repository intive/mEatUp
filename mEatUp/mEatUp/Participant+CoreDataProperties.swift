//
//  Participant+CoreDataProperties.swift
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

extension Participant {

    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var pictureURL: String?
    @NSManaged var userID: String?
    @NSManaged var debt: NSNumber
    @NSManaged var room: FinishedRoom
}
