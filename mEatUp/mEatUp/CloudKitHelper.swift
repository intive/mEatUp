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
    let container: CKContainer
    let publicDB: CKDatabase
    
    init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
    }
    
    func saveRoomRecord(room: Room, completionHandler: (() -> Void)?, errorHandler: ((NSError?) -> Void)?) {
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
            } else {
                errorHandler?(error)
            }
        })
    }
    
    func saveUserRecord(user: User, completionHandler: (() -> Void)?, errorHandler: ((NSError?) -> Void)?) {
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
            } else {
                errorHandler?(error)
            }
        })
    }
    
    func saveRestaurantRecord(restaurant: Restaurant, completionHandler: (() -> Void)?, errorHandler: ((NSError?) -> Void)?) {
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
            } else {
                errorHandler?(error)
            }
        })
    }
    
    func saveUserInRoomRecord(userInRoom: UserInRoom, completionHandler: (() -> Void)?, errorHandler: ((NSError?) -> Void)?) {
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
            } else {
                errorHandler?(error)
            }
        })
    }
    
    func loadRestaurantRecordWithId(restaurantID: Int, completionHandler: ((Restaurant) -> Void), errorHandler: ((NSError?) -> Void)?) {
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
                errorHandler?(error)
            }
        }
        completionHandler(newRestaurant)
    }
    
    func loadUserRecordWithId(fbID: String, completionHandler: ((User) -> Void), errorHandler: ((NSError?) -> Void)?) {
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
                errorHandler?(error)
            }
        }
        completionHandler(newUser)
    }
    
    func loadRoomRecordWithId(roomID: Int, completionHandler: ((Room) -> Void), errorHandler: ((NSError?) -> Void)?) {
        let newRoom = Room()
        newRoom.roomID = roomID
        
        let predicate = NSPredicate(format: "%@ == %@", RoomProperties.roomID.rawValue ,roomID)
        let query = CKQuery(recordType: Room.entityName, predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for room in results {
                        newRoom.title = room[RoomProperties.title.rawValue] as? String
                        if let accessType = room[RoomProperties.accessType.rawValue] as? Int {
                            newRoom.accessType = AccessType(rawValue: accessType)
                        }
                        if let restaurantID = room[RoomProperties.restaurantID.rawValue] as? Int {
                            self.loadRestaurantRecordWithId(restaurantID, completionHandler: {
                                restaurant in
                                    newRoom.restaurant = restaurant
                            }, errorHandler: nil)
                        }
                        newRoom.maxCount = room[RoomProperties.maxCount.rawValue] as? Int
                        newRoom.date = room[RoomProperties.date.rawValue] as? NSDate
                        if let ownerID = room[RoomProperties.ownerID.rawValue] as? String {
                            self.loadUserRecordWithId(ownerID, completionHandler: {
                                owner in
                                    newRoom.owner = owner
                            }, errorHandler: nil)
                        }
                        newRoom.didEnd = room[RoomProperties.didEnd.rawValue] as? Bool
                        newRoom.recordID = room.recordID
                    }
                }
            }
            else {
                errorHandler?(error)
            }
        }
        completionHandler(newRoom)
    }
    
    func loadUsersInRoomRecordWithRoomId(roomID: Int, completionHandler: ([User]) -> Void, errorHandler: ((NSError?) -> Void)?) {
        var usersInRoom = [User]()
        
        let predicate = NSPredicate(format: "%@ == %@", RoomProperties.roomID.rawValue ,roomID)
        let query = CKQuery(recordType: UserInRoom.entityName, predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for userInRoom in results {
                        var newUser = User()
                        if let userID = userInRoom[UserInRoomProperties.userID.rawValue] as? String {
                            self.loadUserRecordWithId(userID, completionHandler: {
                                user in
                                    newUser = user
                            }, errorHandler: nil)
                        }
                        usersInRoom.append(newUser)
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
    
    func loadUsersInRoomRecordWithUserId(userID: String, completionHandler: ([Room]) -> Void, errorHandler: ((NSError?) -> Void)?) {
        var roomsForUser = [Room]()
        
        let predicate = NSPredicate(format: "%@ == %@", UserInRoomProperties.userID.rawValue ,userID)
        let query = CKQuery(recordType: UserInRoom.entityName, predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for userInRoom in results {
                        var newRoom = Room()
                        if let roomID = userInRoom[UserInRoomProperties.roomID.rawValue] as? Int {
                            self.loadRoomRecordWithId(roomID, completionHandler: {
                                room in
                                    newRoom = room
                            }, errorHandler: nil)
                        }
                        
                        roomsForUser.append(newRoom)
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
                        if let accessType = room[RoomProperties.accessType.rawValue] as? Int {
                            newRoom.accessType = AccessType(rawValue: accessType)
                        }
                        if let restaurantID = room[RoomProperties.restaurantID.rawValue] as? Int {
                            self.loadRestaurantRecordWithId(restaurantID, completionHandler: {
                                restaurant in
                                    newRoom.restaurant = restaurant
                            }, errorHandler: nil)
                        }
                        newRoom.maxCount = room[RoomProperties.maxCount.rawValue] as? Int
                        newRoom.date = room[RoomProperties.date.rawValue] as? NSDate
                        if let ownerID = room[RoomProperties.ownerID.rawValue] as? String {
                            self.loadUserRecordWithId(ownerID, completionHandler: {
                                owner in
                                    newRoom.owner = owner
                            }, errorHandler: nil)
                        }
                        newRoom.didEnd = room[RoomProperties.didEnd.rawValue] as? Bool
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
    
    func loadUserRoomRecord(fbID: String, completionHandler: (Room) -> Void, errorHandler: ((NSError?) -> Void)?) {
        var resultRoom = Room()
        
        let predicate = NSPredicate(format: "%@ == %@", RoomProperties.ownerID.rawValue, fbID)
        
        let query = CKQuery(recordType: Room.entityName, predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for room in results {
                        let newRoom = Room()
                        
                        newRoom.roomID = room[RoomProperties.roomID.rawValue] as? Int
                        newRoom.title = room[RoomProperties.title.rawValue] as? String
                        if let accessType = room[RoomProperties.accessType.rawValue] as? Int {
                            newRoom.accessType = AccessType(rawValue: accessType)
                        }
                        if let restaurantID = room[RoomProperties.restaurantID.rawValue] as? Int {
                            self.loadRestaurantRecordWithId(restaurantID, completionHandler: {
                                restaurant in
                                newRoom.restaurant = restaurant
                                }, errorHandler: nil)
                        }
                        newRoom.maxCount = room[RoomProperties.maxCount.rawValue] as? Int
                        newRoom.date = room[RoomProperties.date.rawValue] as? NSDate
                        if let ownerID = room[RoomProperties.ownerID.rawValue] as? String {
                            self.loadUserRecordWithId(ownerID, completionHandler: {
                                owner in
                                newRoom.owner = owner
                                }, errorHandler: nil)
                        }
                        newRoom.didEnd = room[RoomProperties.didEnd.rawValue] as? Bool
                        newRoom.recordID = room.recordID
                        
                        resultRoom = newRoom
                    }
                }
            }
            else {
                errorHandler?(error)
                return
            }
        }
        completionHandler(resultRoom)
    }

    
    func loadInvitedRoomRecords(fbID: String, completionHandler: ([Room]) -> Void, errorHandler: ((NSError?) -> Void)?) {
        var rooms = [Room]()

        let predicate = NSPredicate(format: "%@ == %@", UserInRoomProperties.userID.rawValue ,fbID)
        
        let query = CKQuery(recordType: UserInRoom.entityName, predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                if let results = results {
                    for userInRoom in results {
                        if let roomID = userInRoom[UserInRoomProperties.roomID.rawValue] as? Int {
                            self.loadRoomRecordWithId(roomID, completionHandler: {
                                room in
                                    let newRoom = room
                                    rooms.append(newRoom)
                            }, errorHandler: nil)
                        }
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
    
    func deleteRecord(cloudKitRecord: CloudKitObject, completionHandler: (() -> Void)?, errorHandler: ((NSError?) -> Void)?) {
        if let recordID = cloudKitRecord.recordID {
            publicDB.deleteRecordWithID(recordID, completionHandler: { recordID, error in
                if error == nil {
                    completionHandler?()
                }
                else {
                    errorHandler?(error)
                }
            })
        }
    }
}
