//
//  CoreDataController.swift
//  mEatUp
//
//  Created by Maciej Plewko on 14.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController: NSObject {
    var context: NSManagedObjectContext
    
    override init() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        context = appDelegate.managedObjectContext
    }
    
    func deleteAllFinishedRoom() {
        let requestRooms = NSFetchRequest(entityName: "FinishedRoom")
        do {
            let rooms = try context.executeFetchRequest(requestRooms)
            
            if rooms.count > 0 {
                
                for result: AnyObject in rooms{
                    context.deleteObject(result as! NSManagedObject)
                    print("NSManagedObject has been Deleted")
                }
                try context.save() }
        } catch {
            print("Deleting test finished rooms failed")
        }
        
    }
    
    // Added for testing Core Data, SettlementListViewController and SettlementViewController
    func addTestFinishedRooms() {
        deleteAllFinishedRoom()
        if let roomDescription = NSEntityDescription.entityForName(FinishedRoom.entityName(), inManagedObjectContext: self.context) {
            let room1 = FinishedRoom(entity: roomDescription, insertIntoManagedObjectContext: self.context)
            room1.roomID = 1
            room1.owner = "Kobe Bryant"
            room1.restaurant = "Krowa na Deptaku"
            room1.title = "Krowa z Lakersami"
            room1.date = NSDate()
            
            let room2 = FinishedRoom(entity: roomDescription, insertIntoManagedObjectContext: self.context)
            room2.roomID = 2
            room2.owner = "Hieronim Lis"
            room2.restaurant = "Na językach"
            room2.title = "Lunch na językach"
            room2.date = NSDate()
            
            let room3 = FinishedRoom(entity: roomDescription, insertIntoManagedObjectContext: self.context)
            room3.roomID = 3
            room3.owner = "Zygmunt Chajzer"
            room3.restaurant = "Pizzeria Pepperoni"
            room3.title = "Czwartkowy lunch iOS"
            room3.date = NSDate()
            
            do {
                try context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
                print("Saving test finished rooms failed")
            }
            
            if let participantDescription = NSEntityDescription.entityForName(Participant.entityName(), inManagedObjectContext: self.context) {
                let participant1 = Participant(entity: participantDescription, insertIntoManagedObjectContext: self.context)
                participant1.firstName = "Maciej"
                participant1.lastName = "Plewko"
                participant1.room = room1
                participant1.userID = 1
                participant1.debt = 10.0
                participant1.pictureURL = "https://static.xx.fbcdn.net/rsrc.php/yl/r/H3nktOa7ZMg.ico"
                
                let participant2 = Participant(entity: participantDescription, insertIntoManagedObjectContext: self.context)
                participant2.firstName = "Krzysztof"
                participant2.lastName = "Przybysz"
                participant2.room = room1
                participant2.userID = 2
                participant2.debt = 0.0
                participant2.pictureURL = "https://static.xx.fbcdn.net/rsrc.php/yl/r/H3nktOa7ZMg.ico"
                
                let participant3 = Participant(entity: participantDescription, insertIntoManagedObjectContext: self.context)
                participant3.firstName = "Paweł"
                participant3.lastName = "Knuth"
                participant3.room = room1
                participant3.userID = 3
                participant3.debt = 0.0
                participant3.pictureURL = "https://static.xx.fbcdn.net/rsrc.php/yl/r/H3nktOa7ZMg.ico"
                
                let particpants1 = room1.mutableSetValueForKey("participants")
                particpants1.addObjectsFromArray([participant1, participant2, participant3])
                
                let participant4 = Participant(entity: participantDescription, insertIntoManagedObjectContext: self.context)
                participant4.firstName = "Jan"
                participant4.lastName = "Kowalski"
                participant4.room = room2
                participant4.userID = 4
                participant4.debt = 5.0
                participant4.pictureURL = "https://static.xx.fbcdn.net/rsrc.php/yl/r/H3nktOa7ZMg.ico"
                
                let participant5 = Participant(entity: participantDescription, insertIntoManagedObjectContext: self.context)
                participant5.firstName = "Zenon"
                participant5.lastName = "Kawa"
                participant5.room = room2
                participant5.userID = 5
                participant5.debt = 5.0
                participant5.pictureURL = "https://static.xx.fbcdn.net/rsrc.php/yl/r/H3nktOa7ZMg.ico"
                
                let participant6 = Participant(entity: participantDescription, insertIntoManagedObjectContext: self.context)
                participant6.firstName = "John"
                participant6.lastName = "Smith"
                participant6.room = room2
                participant6.userID = 6
                participant6.debt = -50.0
                participant6.pictureURL = "https://static.xx.fbcdn.net/rsrc.php/yl/r/H3nktOa7ZMg.ico"
                
                let particpants2 = room2.mutableSetValueForKey("participants")
                particpants2.addObjectsFromArray([participant4, participant5, participant6])
        
                do {
                    try context.save()
                } catch let error as NSError {
                    print(error.localizedDescription)
                    print("Saving test finished rooms participants failed")
                }
            }
        }
    }
    
}
