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
        if let restaurantRecordID = room.restaurant?.recordID {
            roomRecord.setValue(CKReference(recordID: restaurantRecordID, action: .DeleteSelf), forKey: RoomProperties.restaurantID.rawValue)
        }
        roomRecord.setValue(room.maxCount, forKey: RoomProperties.maxCount.rawValue)
        roomRecord.setValue(room.date, forKey: RoomProperties.date.rawValue)
        roomRecord.setValue(room.didEnd, forKey: RoomProperties.didEnd.rawValue)
        if let ownerRecordID = room.owner?.recordID {
            roomRecord.setValue(CKReference(recordID: ownerRecordID, action: .DeleteSelf), forKey: RoomProperties.ownerID.rawValue)
        }
        
            self.publicDB.saveRecord(roomRecord, completionHandler: { (record, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    if error == nil {
                        print("room saved")
                        room.recordID = record?.recordID
                        completionHandler?()
                    } else {
                        errorHandler?(error)
                    }
                })
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
        
            self.publicDB.saveRecord(userRecord, completionHandler: { (record, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    if error == nil {
                        print("user saved")
                        user.recordID = record?.recordID
                        completionHandler?()
                    } else {
                        errorHandler?(error)
                    }
                })
            })
        
    }
    
    func saveRestaurantRecord(restaurant: Restaurant, completionHandler: (() -> Void)?, errorHandler: ((NSError?) -> Void)?) {
        let restaurantRecord: CKRecord
        
        if let recordID = restaurant.recordID {
            restaurantRecord = CKRecord(recordType: Restaurant.entityName, recordID: recordID)
        } else {
            restaurantRecord = CKRecord(recordType: Restaurant.entityName)
        }
        
        restaurantRecord.setValue(restaurant.name, forKey: RestaurantProperties.name.rawValue)
        restaurantRecord.setValue(restaurant.address, forKey: RestaurantProperties.address.rawValue)
        
            self.publicDB.saveRecord(restaurantRecord, completionHandler: { (record, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    if error == nil {
                        print("restaurant saved")
                        restaurant.recordID = record?.recordID
                        completionHandler?()
                    } else {
                        errorHandler?(error)
                    }
                })
            })
        
    }
    
    func saveUserInRoomRecord(userInRoom: UserInRoom, completionHandler: (() -> Void)?, errorHandler: ((NSError?) -> Void)?) {
        let userInRoomRecord: CKRecord
        
        if let recordID = userInRoom.recordID {
            userInRoomRecord = CKRecord(recordType: UserInRoom.entityName, recordID: recordID)
        } else {
            userInRoomRecord = CKRecord(recordType: UserInRoom.entityName)
        }
        
        userInRoomRecord.setValue(userInRoom.user?.recordID, forKey: UserInRoomProperties.userRecordID.rawValue)
        userInRoomRecord.setValue(userInRoom.room?.recordID, forKey: UserInRoomProperties.roomRecordID.rawValue)
        userInRoomRecord.setValue(userInRoom.confirmationStatus?.hashValue, forKey: UserInRoomProperties.confirmationStatus.rawValue)
        
            self.publicDB.saveRecord(userInRoomRecord, completionHandler: { (record, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    if error == nil {
                        userInRoom.recordID = record?.recordID
                        completionHandler?()
                    } else {
                        errorHandler?(error)
                    }
                })
            })
        
    }
    
    func loadRestaurantRecord(restaurantRecordID: CKRecordID, completionHandler: ((Restaurant) -> Void), errorHandler: ((NSError?) -> Void)?) {
        let newRestaurant = Restaurant()

            self.publicDB.fetchRecordWithID(restaurantRecordID) { result, error in
                dispatch_async(dispatch_get_main_queue(), {
                    if error == nil {
                        if let result = result {
                            newRestaurant.name = result[RestaurantProperties.name.rawValue] as? String
                            newRestaurant.address = result[RestaurantProperties.address.rawValue] as? String
                            newRestaurant.recordID = result.recordID
                            
                        }
                    }
                    else {
                        errorHandler?(error)
                    }
                    completionHandler(newRestaurant)
                })
            }
        
    }
    
    func loadUserRecordWithFbId(fbID: String, completionHandler: ((User) -> Void), errorHandler: ((NSError?) -> Void)?) {
        let newUser = User()
        newUser.fbID = fbID
        
        let predicate = NSPredicate(format: "fbID == %@", fbID)
//        let predicate = NSPredicate(format: "fbID == testfbid")

        let query = CKQuery(recordType: User.entityName, predicate: predicate)
        
            self.publicDB.performQuery(query, inZoneWithID: nil) { results, error in
                dispatch_async(dispatch_get_main_queue(), {
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
                    completionHandler(newUser)
                })
            }
        
    }
    
    func loadUserRecord(userRecordID: CKRecordID, completionHandler: ((User) -> Void), errorHandler: ((NSError?) -> Void)?) {
        let newUser = User()
        
            self.publicDB.fetchRecordWithID(userRecordID) { result, error in
                dispatch_async(dispatch_get_main_queue(), {
                    if error == nil {
                        if let result = result {
                                newUser.name = result[UserProperties.name.rawValue] as? String
                                newUser.surname = result[UserProperties.surname.rawValue] as? String
                                newUser.photo = result[UserProperties.photo.rawValue] as? String
                                newUser.recordID = result.recordID
                        }
                    }
                    else {
                        errorHandler?(error)
                    }
                    completionHandler(newUser)
                })
            }
        
    }
    
    func loadRoomRecord(roomRecordID: CKRecordID, completionHandler: ((Room) -> Void), errorHandler: ((NSError?) -> Void)?) {
        let newRoom = Room()
        
            self.publicDB.fetchRecordWithID(roomRecordID) { result, error in
                dispatch_async(dispatch_get_main_queue(), {
                    if error == nil {
                        if let result = result {
                                newRoom.title = result[RoomProperties.title.rawValue] as? String
                                if let accessType = result[RoomProperties.accessType.rawValue] as? Int {
                                    newRoom.accessType = AccessType(rawValue: accessType)
                                }
                                if let restaurantID = result[RoomProperties.restaurantID.rawValue] as? CKRecordID {
                                    self.loadRestaurantRecord(restaurantID, completionHandler: {
                                        restaurant in
                                        newRoom.restaurant = restaurant
                                        }, errorHandler: nil)
                                }
                                newRoom.maxCount = result[RoomProperties.maxCount.rawValue] as? Int
                                newRoom.date = result[RoomProperties.date.rawValue] as? NSDate
                                if let ownerID = result[RoomProperties.ownerID.rawValue] as? CKRecordID {
                                    self.loadUserRecord(ownerID, completionHandler: {
                                        owner in
                                        newRoom.owner = owner
                                        }, errorHandler: nil)
                                }
                                newRoom.didEnd = result[RoomProperties.didEnd.rawValue] as? Bool
                                newRoom.recordID = result.recordID
                            
                        }
                    }
                    else {
                        errorHandler?(error)
                    }
                    completionHandler(newRoom)
                })
            }
        
    }
    
    func loadUsersInRoomRecordWithRoomId(roomRecordID: CKRecordID, completionHandler: ([User]) -> Void, errorHandler: ((NSError?) -> Void)?) {
        var usersInRoom = [User]()
        
        let predicate = NSPredicate(format: "%@ == %@", UserInRoomProperties.roomRecordID.rawValue ,roomRecordID)
        let query = CKQuery(recordType: UserInRoom.entityName, predicate: predicate)
        
            self.publicDB.performQuery(query, inZoneWithID: nil) { results, error in
                dispatch_async(dispatch_get_main_queue(), {
                    if error == nil {
                        if let results = results {
                            for userInRoom in results {
                                var newUser = User()
                                if let userID = userInRoom[UserInRoomProperties.userRecordID.rawValue] as? CKRecordID {
                                    self.loadUserRecord(userID, completionHandler: {
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
                    completionHandler(usersInRoom)
                })
            }
        
    }
    
    func loadUsersInRoomRecordWithUserId(userRecordID: CKRecordID, completionHandler: ([Room]) -> Void, errorHandler: ((NSError?) -> Void)?) {
        var roomsForUser = [Room]()
        
        let predicate = NSPredicate(format: "%@ == %@", UserInRoomProperties.userRecordID.rawValue ,userRecordID)
        let query = CKQuery(recordType: UserInRoom.entityName, predicate: predicate)
        
            self.publicDB.performQuery(query, inZoneWithID: nil) { results, error in
                dispatch_async(dispatch_get_main_queue(), {
                    if error == nil {
                        if let results = results {
                            for userInRoom in results {
                                var newRoom = Room()
                                if let roomID = userInRoom[UserInRoomProperties.roomRecordID.rawValue] as? CKRecordID {
                                    self.loadRoomRecord(roomID, completionHandler: {
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
                    completionHandler(roomsForUser)
                })
            }
        
    }
    
    func loadPublicRoomRecords(completionHandler: ([Room]) -> Void, errorHandler: ((NSError?) -> Void)?) {
        var rooms = [Room]()
        
        let predicate = NSPredicate(format: "accessType == 1")
        
        let query = CKQuery(recordType: Room.entityName, predicate: predicate)
        
            self.publicDB.performQuery(query, inZoneWithID: nil) { results, error in
                dispatch_async(dispatch_get_main_queue(), {
                    if error == nil {
                        if let results = results {
                            for room in results {
                                let newRoom = Room()
                                
                                newRoom.title = room[RoomProperties.title.rawValue] as? String
                                if let accessType = room[RoomProperties.accessType.rawValue] as? Int {
                                    newRoom.accessType = AccessType(rawValue: accessType)
                                }
                                if let restaurantID = room[RoomProperties.restaurantID.rawValue] as? CKRecordID {
                                    self.loadRestaurantRecord(restaurantID, completionHandler: {
                                        restaurant in
                                        newRoom.restaurant = restaurant
                                        }, errorHandler: nil)
                                }
                                newRoom.maxCount = room[RoomProperties.maxCount.rawValue] as? Int
                                newRoom.date = room[RoomProperties.date.rawValue] as? NSDate
                                if let ownerID = room[RoomProperties.ownerID.rawValue] as? CKRecordID {
                                    self.loadUserRecord(ownerID, completionHandler: {
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
                    completionHandler(rooms)
                })
            }
        
    }
    
    func loadUserRoomRecord(fbID: String, completionHandler: (Room) -> Void, errorHandler: ((NSError?) -> Void)?) {
        var resultRoom = Room()
        
        let predicate = NSPredicate(format: "%@ == %@", RoomProperties.ownerID.rawValue, fbID)
        
        let query = CKQuery(recordType: Room.entityName, predicate: predicate)
        
            self.publicDB.performQuery(query, inZoneWithID: nil) { results, error in
                dispatch_async(dispatch_get_main_queue(), {
                    if error == nil {
                        if let results = results {
                            for room in results {
                                let newRoom = Room()
                                
                                newRoom.title = room[RoomProperties.title.rawValue] as? String
                                if let accessType = room[RoomProperties.accessType.rawValue] as? Int {
                                    newRoom.accessType = AccessType(rawValue: accessType)
                                }
                                if let restaurantID = room[RoomProperties.restaurantID.rawValue] as? CKRecordID {
                                    self.loadRestaurantRecord(restaurantID, completionHandler: {
                                        restaurant in
                                        newRoom.restaurant = restaurant
                                        }, errorHandler: nil)
                                }
                                newRoom.maxCount = room[RoomProperties.maxCount.rawValue] as? Int
                                newRoom.date = room[RoomProperties.date.rawValue] as? NSDate
                                if let ownerID = room[RoomProperties.ownerID.rawValue] as? CKRecordID {
                                    self.loadUserRecord(ownerID, completionHandler: {
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
                    completionHandler(resultRoom)
                })
            }
        
    }

    
    func loadInvitedRoomRecords(userRecordID: CKRecordID, completionHandler: ([Room]) -> Void, errorHandler: ((NSError?) -> Void)?) {
        var rooms = [Room]()

        let predicate = NSPredicate(format: "%@ == %@ AND %@ == %@", UserInRoomProperties.userRecordID.rawValue ,userRecordID, UserInRoomProperties.confirmationStatus.rawValue, ConfirmationStatus.Invited.hashValue)
        
        let query = CKQuery(recordType: UserInRoom.entityName, predicate: predicate)
        
            self.publicDB.performQuery(query, inZoneWithID: nil) { results, error in
                dispatch_async(dispatch_get_main_queue(), {
                    if error == nil {
                        if let results = results {
                            for userInRoom in results {
                                if let roomID = userInRoom[UserInRoomProperties.roomRecordID.rawValue] as? CKRecordID {
                                    self.loadRoomRecord(roomID, completionHandler: {
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
                    completionHandler(rooms)
                })
            }
        
    }
    
    func loadUserRecords(completionHandler: ([User]) -> Void, errorHandler: ((NSError?) -> Void)?) {
        var users = [User]()
        
        let query = CKQuery(recordType: User.entityName, predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
            self.publicDB.performQuery(query, inZoneWithID: nil) { results, error in
                dispatch_async(dispatch_get_main_queue(), {
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
                    completionHandler(users)
                })
            }
        
    }
    
    func loadRestaurantRecords(completionHandler: ([Restaurant]) -> Void, errorHandler: ((NSError?) -> Void)?) {
        var restaurants = [Restaurant]()
        
        let query = CKQuery(recordType: Restaurant.entityName, predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        
            self.publicDB.performQuery(query, inZoneWithID: nil) { results, error in
                dispatch_async(dispatch_get_main_queue(), {
                    if error == nil {
                        if let results = results {
                            for user in results {
                                let newRestaurant = Restaurant()
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
                    completionHandler(restaurants)
                })
            }
        
    }
    
    func deleteRecord(cloudKitRecord: CloudKitObject, completionHandler: (() -> Void)?, errorHandler: ((NSError?) -> Void)?) {
        if let recordID = cloudKitRecord.recordID {
            
                self.publicDB.deleteRecordWithID(recordID, completionHandler: { recordID, error in
                    dispatch_async(dispatch_get_main_queue(), {
                        if error == nil {
                            completionHandler?()
                        }
                        else {
                            errorHandler?(error)
                        }
                    })
                })
            
        }
    }
}
