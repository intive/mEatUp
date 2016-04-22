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
    
    func editRoomRecord(room: Room, completionHandler: (() -> Void)?, errorHandler: ((NSError?) -> Void)?) {
        publicDB.fetchRecordWithID(room.recordID!, completionHandler: {
            record, error in
            if let record = record {
                record.setValue(room.title, forKey: RoomProperties.title.rawValue)
                record.setValue(room.accessType?.rawValue, forKey: RoomProperties.accessType.rawValue)
                if let restaurantRecordID = room.restaurant?.recordID {
                    record.setValue(CKReference(recordID: restaurantRecordID, action: .DeleteSelf), forKey: RoomProperties.restaurantID.rawValue)
                }
                record.setValue(room.maxCount, forKey: RoomProperties.maxCount.rawValue)
                record.setValue(room.date, forKey: RoomProperties.date.rawValue)
                record.setValue(room.didEnd, forKey: RoomProperties.didEnd.rawValue)
                if let ownerRecordID = room.owner?.recordID {
                    record.setValue(CKReference(recordID: ownerRecordID, action: .DeleteSelf), forKey: RoomProperties.ownerID.rawValue)
                }
                self.publicDB.saveRecord(record, completionHandler: { (record, error) in
                    dispatch_async(dispatch_get_main_queue(), {
                        if error == nil {
                            room.recordID = record?.recordID
                            completionHandler?()
                        } else {
                            errorHandler?(error)
                        }
                    })
                })
            }
        })
    }
    
    func saveRoomRecord(room: Room, completionHandler: (() -> Void)?, errorHandler: ((NSError?) -> Void)?) {
        let roomRecord: CKRecord
        
        if let recordID = room.recordID {
            roomRecord = CKRecord(recordType: Room.entityName, recordID: recordID)
        } else {
            roomRecord = CKRecord(recordType: Room.entityName)
        }
        
        roomRecord.setValue(room.title, forKey: RoomProperties.title.rawValue)
        roomRecord.setValue(room.accessType?.rawValue, forKey: RoomProperties.accessType.rawValue)
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
        
        if let userRecordID = userInRoom.user?.recordID {
            userInRoomRecord.setValue(CKReference(recordID: userRecordID, action: .DeleteSelf), forKey: UserInRoomProperties.userRecordID.rawValue)
        }
        
        if let roomRecordID = userInRoom.room?.recordID{
            userInRoomRecord.setValue(CKReference(recordID: roomRecordID, action: .DeleteSelf), forKey: UserInRoomProperties.roomRecordID.rawValue)
        }
        
        userInRoomRecord.setValue(userInRoom.confirmationStatus?.rawValue, forKey: UserInRoomProperties.confirmationStatus.rawValue)
        
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
                    return
                }
                completionHandler(newRestaurant)
            })
        }
    }
    
    func loadUserRecordWithFbId(fbID: String, completionHandler: ((User) -> Void), errorHandler: ((NSError?) -> Void)?) {
        let newUser = User()
        newUser.fbID = fbID
        
        let predicate = NSPredicate(format: "fbID == %@", fbID)

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
                    return
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
                    return
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
                            if let restaurantID = result[RoomProperties.restaurantID.rawValue] as? CKReference {
                                self.loadRestaurantRecord(restaurantID.recordID, completionHandler: {
                                    restaurant in
                                    newRoom.restaurant = restaurant
                                    if let ownerID = result[RoomProperties.ownerID.rawValue] as? CKReference {
                                        self.loadUserRecord(ownerID.recordID, completionHandler: {
                                            owner in
                                            newRoom.owner = owner
                                            completionHandler(newRoom)
                                        }, errorHandler: nil)
                                    }
                                }, errorHandler: nil)
                            }
                            newRoom.maxCount = result[RoomProperties.maxCount.rawValue] as? Int
                            newRoom.date = result[RoomProperties.date.rawValue] as? NSDate

                            newRoom.didEnd = result[RoomProperties.didEnd.rawValue] as? Bool
                            newRoom.recordID = result.recordID
                    }
                }
                else {
                    errorHandler?(error)
                }
            })
        }
    }
    
    func loadUsersInRoomRecordWithRoomId(roomRecordID: CKRecordID, completionHandler: (User) -> Void, errorHandler: ((NSError?) -> Void)?) {
        let predicate = NSPredicate(format: "roomRecordID == %@", CKReference(recordID: roomRecordID, action: .None))
        let query = CKQuery(recordType: UserInRoom.entityName, predicate: predicate)
        
        self.publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            dispatch_async(dispatch_get_main_queue(), {
                if error == nil {
                    if let results = results {
                        for userInRoom in results {
                            if let userID = userInRoom[UserInRoomProperties.userRecordID.rawValue] as? CKReference {
                                self.loadUserRecord(userID.recordID, completionHandler: {
                                    user in
                                        completionHandler(user)
                                }, errorHandler: nil)
                            }
                        }
                    }
                }
                else {
                    errorHandler?(error)
                }
            })
        }
    }
    
    func loadUsersInRoomRecordWithUserId(userRecordID: CKRecordID, completionHandler: (Room?) -> Void, errorHandler: ((NSError?) -> Void)?) {
        let predicate = NSPredicate(format: "userRecordID == %@", CKReference(recordID: userRecordID, action: .None))
        let query = CKQuery(recordType: UserInRoom.entityName, predicate: predicate)
        
        self.publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            dispatch_async(dispatch_get_main_queue(), {
                if error == nil {
                    if let results = results {
                        for userInRoom in results {
                            if let roomID = userInRoom[UserInRoomProperties.roomRecordID.rawValue] as? CKReference {
                                self.loadRoomRecord(roomID.recordID, completionHandler: {
                                    room in
                                        completionHandler(room)
                                }, errorHandler: nil)
                            }
                        }
                    }
                    else {
                        completionHandler(nil)
                    }
                }
                else {
                    errorHandler?(error)
                }
            })
        }
    }
    
    func loadUserFinishedRoomRecords(userRecordID: CKRecordID, completionHandler: (Room?) -> Void, errorHandler: ((NSError?) -> Void)?) {
        let predicate = NSPredicate(format: "userRecordID == %@", CKReference(recordID: userRecordID, action: .None))
        let query = CKQuery(recordType: UserInRoom.entityName, predicate: predicate)
        
        self.publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            dispatch_async(dispatch_get_main_queue(), {
                if error == nil {
                    if let results = results {
                        for userInRoom in results {
                            if let roomID = userInRoom[UserInRoomProperties.roomRecordID.rawValue] as? CKReference {
                                self.loadRoomRecord(roomID.recordID, completionHandler: {
                                    room in
                                    if room.didEnd == true {
                                        completionHandler(room)
                                    }
                                }, errorHandler: nil)
                            }
                        }
                    } else {
                        completionHandler(nil)
                    }
                }
                else {
                    errorHandler?(error)
                }
            })
        }
    }
    
    func loadPublicRoomRecords(completionHandler: (Room) -> Void, errorHandler: ((NSError?) -> Void)?) {
        let predicate = NSPredicate(format: "accessType == 2")
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
                            if let restaurantID = room[RoomProperties.restaurantID.rawValue] as? CKReference {
                                self.loadRestaurantRecord(restaurantID.recordID, completionHandler: {
                                    restaurant in
                                        newRoom.restaurant = restaurant
                                        if let ownerID = room[RoomProperties.ownerID.rawValue] as? CKReference {
                                            self.loadUserRecord(ownerID.recordID, completionHandler: {
                                                owner in
                                                    newRoom.owner = owner
                                                    completionHandler(newRoom)
                                            }, errorHandler: nil)
                                        }
                                }, errorHandler: nil)
                            }
                            newRoom.maxCount = room[RoomProperties.maxCount.rawValue] as? Int
                            newRoom.date = room[RoomProperties.date.rawValue] as? NSDate
                            newRoom.didEnd = room[RoomProperties.didEnd.rawValue] as? Bool
                            newRoom.recordID = room.recordID
                        }
                    }
                }
                else {
                    errorHandler?(error)
                }
            })
        }
    }
    
    func loadUserRoomRecord(userRecordID: CKRecordID, completionHandler: (Room?) -> Void, errorHandler: ((NSError?) -> Void)?) {
        let predicate = NSPredicate(format: "ownerID == %@", CKReference(recordID: userRecordID, action: .None))
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
                            if let restaurantID = room[RoomProperties.restaurantID.rawValue] as? CKReference {
                                self.loadRestaurantRecord(restaurantID.recordID, completionHandler: {
                                    restaurant in
                                        newRoom.restaurant = restaurant
                                        newRoom.date = room[RoomProperties.date.rawValue] as? NSDate
                                        if let ownerID = room[RoomProperties.ownerID.rawValue] as? CKReference {
                                            self.loadUserRecord(ownerID.recordID, completionHandler: {
                                                owner in
                                                    newRoom.owner = owner
                                                    completionHandler(newRoom)
                                            }, errorHandler: nil)
                                        }
                                }, errorHandler: nil)
                            }
                            newRoom.maxCount = room[RoomProperties.maxCount.rawValue] as? Int
                            newRoom.didEnd = room[RoomProperties.didEnd.rawValue] as? Bool
                            newRoom.recordID = room.recordID
                        }
                    } else {
                        completionHandler(nil)
                    }
                }
                else {
                    errorHandler?(error)
                }
            })
        }
    }

    
    func loadInvitedRoomRecords(userRecordID: CKRecordID, completionHandler: (Room?) -> Void, errorHandler: ((NSError?) -> Void)?) {
        let predicate = NSPredicate(format: "userRecordID == %@ AND confirmationStatus == 1", CKReference(recordID: userRecordID, action: .None))
        let query = CKQuery(recordType: UserInRoom.entityName, predicate: predicate)
        
        self.publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            dispatch_async(dispatch_get_main_queue(), {
                if error == nil {
                    if let results = results {
                        for userInRoom in results {
                            if let roomID = userInRoom[UserInRoomProperties.roomRecordID.rawValue] as? CKReference {
                                self.loadRoomRecord(roomID.recordID, completionHandler: {
                                    room in
                                        completionHandler(room)
                                }, errorHandler: nil)
                            }
                        }
                    } else {
                        completionHandler(nil)
                    }
                }
                else {
                    errorHandler?(error)
                }
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
    
    func checkIfUserInRoom(roomRecordID: CKRecordID, userRecordID: CKRecordID, completionHandler: (UserInRoom?) -> Void, errorHandler: ((NSError?) -> Void)?) {
        let predicate = NSPredicate(format: "roomRecordID == %@ AND userRecordID = %@", CKReference(recordID: roomRecordID, action: .None), CKReference(recordID: userRecordID, action: .None))
        let query = CKQuery(recordType: UserInRoom.entityName, predicate: predicate)
        
        self.publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            dispatch_async(dispatch_get_main_queue(), {
                if error == nil {
                    if let results = results where results.count > 0 {
                        for userInRoom in results {
                            let newUserInRoom = UserInRoom()
                            newUserInRoom.recordID = userInRoom.recordID
                            completionHandler(newUserInRoom)
                        }
                    } else {
                        completionHandler(nil)
                    }
                }
                else {
                    errorHandler?(error)
                }
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
