//
//  CoreDataController.swift
//  mEatUp
//
//  Created by Maciej Plewko on 14.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController {
    static let sharedInstance = CoreDataController()
    
    private init() {}
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application.
        let modelURL = NSBundle.mainBundle().URLForResource("mEatUp", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("mEatUp.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "mEatup Error", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

    func deleteAllFinishedRoom() {
        let requestRooms = NSFetchRequest(entityName: "FinishedRoom")
        do {
            let rooms = try managedObjectContext.executeFetchRequest(requestRooms)
            
            if rooms.count > 0 {
                for result: AnyObject in rooms{
                    if let result = result as? NSManagedObject {
                        managedObjectContext.deleteObject(result)
                        print("NSManagedObject has been Deleted")
                    }
                }
                try managedObjectContext.save() }
        } catch {
            print("Deleting test finished rooms failed")
        }
        
    }
    
    func addFinishedRoom(id: String, title: String, owner: String, restaurant: String, date: NSDate) -> FinishedRoom? {
        if roomExists(id) == false {
            if let roomDescription = NSEntityDescription.entityForName(FinishedRoom.entityName(), inManagedObjectContext: managedObjectContext) {
                let room = FinishedRoom(entity: roomDescription, insertIntoManagedObjectContext: managedObjectContext)
                room.roomID = id
                room.owner = owner
                room.restaurant = restaurant
                room.title = title
                room.date = date
            
                do {
                    try managedObjectContext.save()
                } catch let error as NSError {
                    print(error.localizedDescription)
                    print("Saving finished room failed")
                }
                
                return room
            }
        }
        
        return nil
    }
    
    func addUserToRoom(id: String, firstname: String, lastname: String, pictureURL: String, room: FinishedRoom) {
        if let participantDescription = NSEntityDescription.entityForName(Participant.entityName(), inManagedObjectContext: managedObjectContext) {
            let participant = Participant(entity: participantDescription, insertIntoManagedObjectContext: managedObjectContext)
            participant.firstName = firstname
            participant.lastName = lastname
            participant.room = room
            participant.userID = id
            participant.debt = 0.00
            participant.pictureURL = pictureURL
            
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                print(error.localizedDescription)
                print("Saving participant room failed")
            }
        }

    }

    func roomExists(roomID: String) -> Bool {
        let roomRequest = NSFetchRequest(entityName: "FinishedRoom")
        roomRequest.predicate = NSPredicate(format: "roomID == %@", roomID)
        var rooms = []
        do {
            rooms = try managedObjectContext.executeFetchRequest(roomRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return rooms.count > 0 ? true : false
    }
    
    // Added for testing Core Data, SettlementListViewController and SettlementViewController
    func addTestFinishedRooms() {
        deleteAllFinishedRoom()
        if let roomDescription = NSEntityDescription.entityForName(FinishedRoom.entityName(), inManagedObjectContext: managedObjectContext) {
            let room1 = FinishedRoom(entity: roomDescription, insertIntoManagedObjectContext: managedObjectContext)
            room1.roomID = "1"
            room1.owner = "Kobe Bryant"
            room1.restaurant = "Krowa na Deptaku"
            room1.title = "Krowa z Lakersami"
            room1.date = NSDate()
            
            let room2 = FinishedRoom(entity: roomDescription, insertIntoManagedObjectContext: managedObjectContext)
            room2.roomID = "2"
            room2.owner = "Hieronim Lis"
            room2.restaurant = "Na językach"
            room2.title = "Lunch na językach"
            room2.date = NSDate()
            
            let room3 = FinishedRoom(entity: roomDescription, insertIntoManagedObjectContext: managedObjectContext)
            room3.roomID = "3"
            room3.owner = "Zygmunt Chajzer"
            room3.restaurant = "Pizzeria Pepperoni"
            room3.title = "Czwartkowy lunch iOS"
            room3.date = NSDate()
            
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                print(error.localizedDescription)
                print("Saving test finished rooms failed")
            }
            
            if let participantDescription = NSEntityDescription.entityForName(Participant.entityName(), inManagedObjectContext: managedObjectContext) {
                let participant1 = Participant(entity: participantDescription, insertIntoManagedObjectContext: managedObjectContext)
                participant1.firstName = "Maciej"
                participant1.lastName = "Plewko"
                participant1.room = room1
                participant1.userID = "1"
                participant1.debt = 10.0
                participant1.pictureURL = "https://scontent.fwaw3-1.fna.fbcdn.net/hprofile-xla1/v/t1.0-1/p50x50/11130302_10206750662389680_4841865343581589964_n.jpg?oh=08a05ee9496bc330aafbefa97943103d&oe=5772445F"
                
                let participant2 = Participant(entity: participantDescription, insertIntoManagedObjectContext: managedObjectContext)
                participant2.firstName = "Krzysztof"
                participant2.lastName = "Przybysz"
                participant2.room = room1
                participant2.userID = "2"
                participant2.debt = 0.0
                participant2.pictureURL = "https://static.xx.fbcdn.net/rsrc.php/yl/r/H3nktOa7ZMg.ico"
                
                let participant3 = Participant(entity: participantDescription, insertIntoManagedObjectContext: managedObjectContext)
                participant3.firstName = "Paweł"
                participant3.lastName = "Knuth"
                participant3.room = room1
                participant3.userID = "3"
                participant3.debt = 0.0
                participant3.pictureURL = "https://static.xx.fbcdn.net/rsrc.php/yl/r/H3nktOa7ZMg.ico"
                
                let participant4 = Participant(entity: participantDescription, insertIntoManagedObjectContext: managedObjectContext)
                participant4.firstName = "Jan"
                participant4.lastName = "Kowalski"
                participant4.room = room2
                participant4.userID = "4"
                participant4.debt = 5.0
                participant4.pictureURL = "https://static.xx.fbcdn.net/rsrc.php/yl/r/H3nktOa7ZMg.ico"
                
                let participant5 = Participant(entity: participantDescription, insertIntoManagedObjectContext: managedObjectContext)
                participant5.firstName = "Zenon"
                participant5.lastName = "Kawa"
                participant5.room = room2
                participant5.userID = "5"
                participant5.debt = 5.0
                participant5.pictureURL = "https://static.xx.fbcdn.net/rsrc.php/yl/r/H3nktOa7ZMg.ico"
                
                let participant6 = Participant(entity: participantDescription, insertIntoManagedObjectContext: managedObjectContext)
                participant6.firstName = "John"
                participant6.lastName = "Smith"
                participant6.room = room2
                participant6.userID = "6"
                participant6.debt = -50.0
                participant6.pictureURL = "https://static.xx.fbcdn.net/rsrc.php/yl/r/H3nktOa7ZMg.ico"
        
                do {
                    try managedObjectContext.save()
                } catch let error as NSError {
                    print(error.localizedDescription)
                    print("Saving test finished rooms participants failed")
                }
            }
        }
    }
    
}
