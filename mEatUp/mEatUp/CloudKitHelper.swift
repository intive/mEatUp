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
    let container : CKContainer
    let publicDB : CKDatabase
    
    init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
    }
    
    func saveRoomRecord(room: Room, completionHandler: (() -> Void)?, errorHandler: (() -> Void)?) {
        let roomRecord: CKRecord
        
        if let recordID = room.recordID {
            roomRecord = CKRecord(recordType: Room.entityName, recordID: recordID)
        } else {
            roomRecord = CKRecord(recordType: Room.entityName)
        }
        
        roomRecord.setValue(room.title, forKey: RoomProperties.title.rawValue)
        roomRecord.setValue(room.accessType?.hashValue, forKey: RoomProperties.accessType.rawValue)
        roomRecord.setValue(room.restaurant?.restaurantID, forKey: RoomProperties.restaurantID.rawValue)
        roomRecord.setValue(room.maxCount, forKey: RoomProperties.maxCount.rawValue)
        roomRecord.setValue(room.date, forKey: RoomProperties.date.rawValue)
        roomRecord.setValue(room.didEnd, forKey: RoomProperties.didEnd.rawValue)
        roomRecord.setValue(room.owner?.fbID, forKey: RoomProperties.ownerID.rawValue)
        
        publicDB.saveRecord(roomRecord, completionHandler: { (record, error) in
            if error == nil {
                room.recordID = record?.recordID
                completionHandler?()
                NSLog("Saved to cloud kit")
            } else {
                errorHandler?()
            }
        })
    }
    
    func saveUserRecord(user: User, completionHandler: (() -> Void)?, errorHandler: (() -> Void)?) {
        let userRecord: CKRecord
        
        if let recordID = user.recordID {
            userRecord = CKRecord(recordType: User.entityName, recordID: recordID)
        } else {
            userRecord = CKRecord(recordType: User.entityName)
        }
        
        userRecord.setValue(user.fbID, forKey: UserProperties.fbID.rawValue)
        userRecord.setValue(user.name, forKey: UserProperties.name.rawValue)
        userRecord.setValue(user.surname, forKey: UserProperties.surname.rawValue)
        userRecord.setValue(user.photo, forKey: UserProperties.photo.rawValue)
        
        publicDB.saveRecord(userRecord, completionHandler: { (record, error) in
            if error == nil {
                user.recordID = record?.recordID
                completionHandler?()
                NSLog("Saved to cloud kit")
            } else {
                errorHandler?()
            }
        })
    }
    
    func saveRestaurantRecord(restaurant: Restaurant, completionHandler: (() -> Void)?, errorHandler: (() -> Void)?) {
        let restaurantRecord: CKRecord
        
        if let recordID = restaurant.recordID {
            restaurantRecord = CKRecord(recordType: Restaurant.entityName, recordID: recordID)
        } else {
            restaurantRecord = CKRecord(recordType: Restaurant.entityName)
        }
        
        restaurantRecord.setValue(restaurant.restaurantID, forKey: RestaurantProperties.restaurantID.rawValue)
        restaurantRecord.setValue(restaurant.name, forKey: RestaurantProperties.name.rawValue)
        restaurantRecord.setValue(restaurant.address, forKey: RestaurantProperties.address.rawValue)
        
        publicDB.saveRecord(restaurantRecord, completionHandler: { (record, error) in
            if error == nil {
                restaurant.recordID = record?.recordID
                completionHandler?()
                NSLog("Saved to cloud kit")
            } else {
                errorHandler?()
            }
        })
    }
    
    func saveUserInRoomRecord(userInRoom: UserInRoom, completionHandler: (() -> Void)?, errorHandler: (() -> Void)?) {
        let userInRoomRecord: CKRecord
        
        if let recordID = userInRoom.recordID {
            userInRoomRecord = CKRecord(recordType: UserInRoom.entityName, recordID: recordID)
        } else {
            userInRoomRecord = CKRecord(recordType: UserInRoom.entityName)
        }
        
        userInRoomRecord.setValue(userInRoom.user?.fbID, forKey: UserInRoomProperties.userID.rawValue)
        userInRoomRecord.setValue(userInRoom.room?.roomID, forKey: UserInRoomProperties.roomID.rawValue)
        userInRoomRecord.setValue(userInRoom.confirmationStatus?.hashValue, forKey: UserInRoomProperties.confirmationStatus.rawValue)
        
        publicDB.saveRecord(userInRoomRecord, completionHandler: { (record, error) in
            if error == nil {
                userInRoom.recordID = record?.recordID
                completionHandler?()
                NSLog("Saved to cloud kit")
            } else {
                errorHandler?()
            }
        })
    }
    
    func loadRestaurantRecordWithId(restaurantID: Int) -> Restaurant {
        let newRestaurant = Restaurant()
        newRestaurant.restaurantID = restaurantID
        
        let predicate = NSPredicate(format: "%@ == %@", RestaurantProperties.restaurantID.rawValue, restaurantID)
        let query = CKQuery(recordType: Restaurant.entityName, predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for restaurant in results {
                        newRestaurant.name = restaurant[RestaurantProperties.name.rawValue] as? String
                        newRestaurant.address = restaurant[RestaurantProperties.address.rawValue] as? String
                        newRestaurant.recordID = restaurant.recordID
                    }
                }
            }
            else {
                print(error)
            }
        }
        return newRestaurant
    }
    
    func loadUserRecordWithId(fbID: String) -> User {
        let newUser = User()
        newUser.fbID = fbID
        
        let predicate = NSPredicate(format: "%@ == %@", UserProperties.fbID.rawValue ,fbID)
        let query = CKQuery(recordType: User.entityName, predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for user in results {
                        newUser.name = user[UserProperties.name.rawValue] as? String
                        newUser.surname = user[UserProperties.surname.rawValue] as? String
                        newUser.photo = user[UserProperties.photo.rawValue] as? String
                        newUser.recordID = user.recordID
                    }
                }
            }
            else {
                print(error)
            }
        }
        return newUser
    }
    
    func loadRoomRecordWithId(roomID: Int) -> Room {
        let newRoom = Room()
        newRoom.roomID = roomID
        
        let predicate = NSPredicate(format: "%@ == %@", RoomProperties.roomID.rawValue ,roomID)
        let query = CKQuery(recordType: Room.entityName, predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for room in results {
                        newRoom.title = room[RoomProperties.title.rawValue] as? String
                        newRoom.accessType = AccessType(rawValue: room[RoomProperties.accessType.rawValue] as! Int)
                        newRoom.restaurant = self.loadRestaurantRecordWithId(room[RoomProperties.restaurantID.rawValue] as! Int)
                        newRoom.maxCount = room[RoomProperties.maxCount.rawValue] as? Int
                        newRoom.date = room[RoomProperties.date.rawValue] as? NSDate
                        newRoom.owner = self.loadUserRecordWithId(room[RoomProperties.ownerID.rawValue] as! String)
                        newRoom.didEnd = room[RoomProperties.didEnd.rawValue] as! Bool
                        newRoom.recordID = room.recordID
                    }
                }
            }
            else {
                print(error)
            }
        }
        return newRoom
    }
    
    func loadUsersInRoomRecordWithRoomId(roomID: Int, completionHandler: ([UserInRoom]) -> Void, errorHandler: ((NSError?) -> Void)?) {
        var usersInRoom = [UserInRoom]()
        
        let predicate = NSPredicate(format: "%@ == %@", RoomProperties.roomID.rawValue ,roomID)
        let query = CKQuery(recordType: UserInRoom.entityName, predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for userInRoom in results {
                        let newUserInRoom = UserInRoom()
                        newUserInRoom.user = self.loadUserRecordWithId(userInRoom[UserInRoomProperties.userID.rawValue] as! String)
                        newUserInRoom.room = self.loadRoomRecordWithId(userInRoom[UserInRoomProperties.roomID.rawValue] as! Int)
                        newUserInRoom.confirmationStatus = ConfirmationStatus(rawValue: userInRoom[UserInRoomProperties.confirmationStatus.rawValue] as! Int)
                        newUserInRoom.recordID = userInRoom.recordID
                        
                        usersInRoom.append(newUserInRoom)
                    }
                }
            }
            else {
                errorHandler?(error)
                return
            }
        }
        completionHandler(usersInRoom)
    }
    
    func loadUsersInRoomRecordWithUserId(userID: Int, completionHandler: ([UserInRoom]) -> Void, errorHandler: ((NSError?) -> Void)?) {
        var roomsForUser = [UserInRoom]()
        
        let predicate = NSPredicate(format: "%@ == %@", UserInRoomProperties.userID.rawValue ,userID)
        let query = CKQuery(recordType: UserInRoom.entityName, predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for userInRoom in results {
                        let newUserInRoom = UserInRoom()
                        newUserInRoom.user = self.loadUserRecordWithId(userInRoom[UserInRoomProperties.userID.rawValue] as! String)
                        newUserInRoom.room = self.loadRoomRecordWithId(userInRoom[UserInRoomProperties.roomID.rawValue] as! Int)
                        newUserInRoom.confirmationStatus = ConfirmationStatus(rawValue: userInRoom[UserInRoomProperties.confirmationStatus.rawValue] as! Int)
                        newUserInRoom.recordID = userInRoom.recordID
                        
                        roomsForUser.append(newUserInRoom)
                    }
                }
            }
            else {
                errorHandler?(error)
                return
            }
        }
        completionHandler(roomsForUser)
    }
    
    func loadPublicRoomRecords(completionHandler: ([Room]) -> Void, errorHandler: ((NSError?) -> Void)?) {
        var rooms = [Room]()
        
        let predicate = NSPredicate(format: "%@ == 0", RoomProperties.accessType.rawValue)
        
        let query = CKQuery(recordType: Room.entityName, predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for room in results {
                        let newRoom = Room()
                        
                        newRoom.roomID = room[RoomProperties.roomID.rawValue] as? Int
                        newRoom.title = room[RoomProperties.title.rawValue] as? String
                        newRoom.accessType = AccessType(rawValue: room[RoomProperties.accessType.rawValue] as! Int)
                        newRoom.restaurant = self.loadRestaurantRecordWithId(room[RoomProperties.restaurantID.rawValue] as! Int)
                        newRoom.maxCount = room[RoomProperties.maxCount.rawValue] as? Int
                        newRoom.date = room[RoomProperties.date.rawValue] as? NSDate
                        newRoom.owner = self.loadUserRecordWithId(room[RoomProperties.ownerID.rawValue] as! String)
                        newRoom.didEnd = room[RoomProperties.didEnd.rawValue] as! Bool
                        newRoom.recordID = room.recordID
                        
                        rooms.append(newRoom)
                    }
                }
            }
            else {
                errorHandler?(error)
                return
            }
        }
        completionHandler(rooms)
    }
    
    func loadInvitedRoomRecords(fbID: String, completionHandler: ([Room]) -> Void, errorHandler: ((NSError?) -> Void)?) {
        var rooms = [Room]()

        let predicate = NSPredicate(format: "%@ == %@", UserInRoomProperties.userID.rawValue ,fbID)
        
        let query = CKQuery(recordType: UserInRoom.entityName, predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for userInRoom in results {
                        let newRoom = self.loadRoomRecordWithId(userInRoom[UserInRoomProperties.roomID.rawValue] as! Int)
                        
                        rooms.append(newRoom)
                    }
                }
            }
            else {
                errorHandler?(error)
                return
            }
        }
        completionHandler(rooms)
    }
    
    func loadUserRecords(completionHandler: ([User]) -> Void, errorHandler: ((NSError?) -> Void)?) {
        var users = [User]()
        
        let query = CKQuery(recordType: User.entityName, predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for user in results {
                        let newUser = User()
                        newUser.fbID = user[UserProperties.fbID.rawValue] as? String
                        newUser.name = user[UserProperties.name.rawValue] as? String
                        newUser.surname = user[UserProperties.surname.rawValue] as? String
                        newUser.photo = user[UserProperties.photo.rawValue] as? String
                        newUser.recordID = user.recordID
                        
                        users.append(newUser)
                    }
                }
            }
            else {
                errorHandler?(error)
                return
            }
        }
        completionHandler(users)
    }
    
    func loadRestaurantRecords(completionHandler: ([Restaurant]) -> Void, errorHandler: ((NSError?) -> Void)?) {
        var restaurants = [Restaurant]()
        
        let query = CKQuery(recordType: Restaurant.entityName, predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for user in results {
                        let newRestaurant = Restaurant()
                        newRestaurant.restaurantID = user[RestaurantProperties.restaurantID.rawValue] as? Int
                        newRestaurant.name = user[RestaurantProperties.name.rawValue] as? String
                        newRestaurant.address = user[RestaurantProperties.address.rawValue] as? String
                        newRestaurant.recordID = user.recordID
                        
                        restaurants.append(newRestaurant)
                    }
                }
            }
            else {
                errorHandler?(error)
                return
            }
        }
        completionHandler(restaurants)
    }
    
    func deleteRecord(cloudKitRecord: CloudKitObject, completionHandler: (() -> Void)?, errorHandler: (() -> Void)?) {
        if let recordID = cloudKitRecord.recordID {
            publicDB.deleteRecordWithID(recordID, completionHandler: { recordID, error in
                if error != nil {
                    errorHandler?()
                }
                else {
                    completionHandler?()
                }
            })
        }
    }
}