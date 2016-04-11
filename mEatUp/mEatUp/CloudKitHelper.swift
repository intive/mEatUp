//
//  CloudKitHelper.swift
//  mEatUp
//
//  Created by Paweł Knuth on 11.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitHelper {
    var container : CKContainer
    var publicDB : CKDatabase
    let privateDB : CKDatabase
    
    init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }
    
    func saveRoomRecord(room: Room) {
        let roomRecord: CKRecord
        
        if let recordID = room.recordID {
            roomRecord = CKRecord(recordType: "Room", recordID: recordID)
        } else {
            roomRecord = CKRecord(recordType: "Room")
        }
        
        roomRecord.setValue(room.title, forKey: "title")
        roomRecord.setValue(room.accessType?.hashValue, forKey: "accessType")
        roomRecord.setValue(room.restaurant?.restaurantID, forKey: "restaurantId")
        roomRecord.setValue(room.maxCount, forKey: "maxCount")
        roomRecord.setValue(room.date, forKey: "date")
        roomRecord.setValue(room.didEnd, forKey: "didEnd")
        roomRecord.setValue(room.owner?.fbID, forKey: "owner")
        
        publicDB.saveRecord(roomRecord, completionHandler: { (record, error) in
            NSLog("Saved to cloud kit")
        })
    }
    
    func saveUserRecord(user: User) {
        let userRecord: CKRecord
        
        if let recordID = user.recordID {
            userRecord = CKRecord(recordType: "User", recordID: recordID)
        } else {
            userRecord = CKRecord(recordType: "User")
        }
        
        userRecord.setValue(user.fbID, forKey: "fbID")
        userRecord.setValue(user.name, forKey: "name")
        userRecord.setValue(user.surname, forKey: "surname")
        userRecord.setValue(user.photo, forKey: "photo")
        
        publicDB.saveRecord(userRecord, completionHandler: { (record, error) in
            NSLog("Saved to cloud kit")
        })
    }
    
    func saveRestaurantRecord(restaurant: Restaurant) {
        let restaurantRecord: CKRecord
        
        if let recordID = restaurant.recordID {
            restaurantRecord = CKRecord(recordType: "Restaurant", recordID: recordID)
        } else {
            restaurantRecord = CKRecord(recordType: "Restaurant")
        }
        
        restaurantRecord.setValue(restaurant.restaurantID, forKey: "restaurantID")
        restaurantRecord.setValue(restaurant.name, forKey: "name")
        restaurantRecord.setValue(restaurant.address, forKey: "address")
        
        publicDB.saveRecord(restaurantRecord, completionHandler: { (record, error) in
            NSLog("Saved to cloud kit")
        })
    }
    
    func saveUserInRoomRecord(userInRoom: UserInRoom) {
        let userInRoomRecord: CKRecord
        
        if let recordID = userInRoom.recordID {
            userInRoomRecord = CKRecord(recordType: "UserInRoom", recordID: recordID)
        } else {
            userInRoomRecord = CKRecord(recordType: "UserInRoom")
        }
        
        userInRoomRecord.setValue(userInRoom.user?.fbID, forKey: "userID")
        userInRoomRecord.setValue(userInRoom.room?.roomID, forKey: "roomID")
        userInRoomRecord.setValue(userInRoom.confirmationStatus?.hashValue, forKey: "address")
        
        publicDB.saveRecord(userInRoomRecord, completionHandler: { (record, error) in
            NSLog("Saved to cloud kit")
        })
    }
    
    func loadRestaurantRecordWithId(restaurantID: Int) -> Restaurant {
        let newRestaurant = Restaurant()
        newRestaurant.restaurantID = restaurantID
        
        let predicate = NSPredicate(format: "restaurantID == %@", restaurantID)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for restaurant in results {
                        newRestaurant.name = restaurant["name"] as? String
                        newRestaurant.address = restaurant["address"] as? String
                        newRestaurant.recordID = restaurant.recordID
                    }
                }
            }
            else {
                print(error)
                return
            }
        }
        return newRestaurant
    }
    
    func loadUserRecordWithId(fbID: String) -> User {
        let newUser = User()
        newUser.fbID = fbID
        
        let predicate = NSPredicate(format: "fbID == %@", fbID)
        let query = CKQuery(recordType: "User", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for user in results {
                        newUser.name = user["name"] as? String
                        newUser.surname = user["surname"] as? String
                        newUser.photo = user["photo"] as? String
                        newUser.recordID = user.recordID
                    }
                }
            }
            else {
                print(error)
                return
            }
        }
        return newUser
    }
    
    func loadRoomRecordWithId(roomID: Int) -> Room {
        let newRoom = Room()
        newRoom.roomID = roomID
        
        let predicate = NSPredicate(format: "roomID == %@", roomID)
        let query = CKQuery(recordType: "Room", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for room in results {
                        newRoom.title = room["title"] as? String
                        newRoom.accessType = AccessType(rawValue: room["accessType"] as! Int)
                        newRoom.restaurant = self.loadRestaurantRecordWithId(room["restaurantID"] as! Int)
                        newRoom.maxCount = room["maxCount"] as? Int
                        newRoom.date = room["date"] as? NSDate
                        newRoom.owner = self.loadUserRecordWithId(room["ownerID"] as! String)
                        newRoom.didEnd = room["didEnd"] as! Bool
                        newRoom.recordID = room.recordID
                    }
                }
            }
            else {
                print(error)
                return
            }
        }
        return newRoom
    }
    
    func loadUsersInRoomRecordWithRoomId(roomID: Int) -> [UserInRoom] {
        var usersInRoom = [UserInRoom]()
        
        let predicate = NSPredicate(format: "roomID == %@", roomID)
        let query = CKQuery(recordType: "UserInRoom", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for userInRoom in results {
                        let newUserInRoom = UserInRoom()
                        newUserInRoom.user = self.loadUserRecordWithId(userInRoom["fbID"] as! String)
                        newUserInRoom.room = self.loadRoomRecordWithId(userInRoom["roomID"] as! Int)
                        newUserInRoom.confirmationStatus = ConfirmationStatus(rawValue: userInRoom["confirmationStatus"] as! Int)
                        newUserInRoom.recordID = userInRoom.recordID
                        
                        usersInRoom.append(newUserInRoom)
                    }
                }
            }
            else {
                print(error)
                return
            }
        }
        return usersInRoom
    }
    
    func loadUsersInRoomRecordWithUserId(userID: Int) -> [UserInRoom] {
        var roomsForUser = [UserInRoom]()
        
        let predicate = NSPredicate(format: "userID == %@", userID)
        let query = CKQuery(recordType: "UserInRoom", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for userInRoom in results {
                        let newUserInRoom = UserInRoom()
                        newUserInRoom.user = self.loadUserRecordWithId(userInRoom["fbID"] as! String)
                        newUserInRoom.room = self.loadRoomRecordWithId(userInRoom["roomID"] as! Int)
                        newUserInRoom.confirmationStatus = ConfirmationStatus(rawValue: userInRoom["confirmationStatus"] as! Int)
                        newUserInRoom.recordID = userInRoom.recordID
                        
                        roomsForUser.append(newUserInRoom)
                    }
                }
            }
            else {
                print(error)
                return
            }
        }
        return roomsForUser
    }
    
    func loadPublicRoomRecords() -> [Room] {
        var rooms = [Room]()
        
        let predicate = NSPredicate(format: "(accessType == 0)")
        
        let query = CKQuery(recordType: "Room", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for room in results {
                        let newRoom = Room()
                        
                        newRoom.title = room["title"] as? String
                        newRoom.accessType = AccessType(rawValue: room["accessType"] as! Int)
                        newRoom.restaurant = self.loadRestaurantRecordWithId(room["restaurantID"] as! Int)
                        newRoom.maxCount = room["maxCount"] as? Int
                        newRoom.date = room["date"] as? NSDate
                        newRoom.owner = self.loadUserRecordWithId(room["ownerID"] as! String)
                        newRoom.didEnd = room["didEnd"] as! Bool
                        newRoom.recordID = room.recordID
                        
                        rooms.append(newRoom)
                    }
                }
            }
            else {
                print(error)
                return
            }
        }
        return rooms
    }
    
    func loadInvitedRoomRecords(fbID: String) -> [Room] {
        var rooms = [Room]()

        let predicate = NSPredicate(format: "fbID == %@", fbID)
        
        let query = CKQuery(recordType: "UserInRoom", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for userInRoom in results {
                        let newRoom = self.loadRoomRecordWithId(userInRoom["roomID"] as! Int)
                        
                        rooms.append(newRoom)
                    }
                }
            }
            else {
                print(error)
                return
            }
        }
        return rooms
    }
    
    func loadUserRecords() -> [User] {
        var users = [User]()
        
        let query = CKQuery(recordType: "User", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for user in results {
                        let newUser = User()
                        newUser.name = user["name"] as? String
                        newUser.surname = user["surname"] as? String
                        newUser.photo = user["photo"] as? String
                        newUser.recordID = user.recordID
                        
                        users.append(newUser)
                    }
                }
            }
            else {
                print(error)
                return
            }
        }
        return users
    }
    
    func deleteRecord(cloudKitRecord: CloudKitObject ) {
        if let recordID = cloudKitRecord.recordID {
            publicDB.deleteRecordWithID(recordID, completionHandler: { recordID, error in
                if error != nil {
                    print(error)
                }
            })
        }
    }
}