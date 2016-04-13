//
//  RoomListViewController.swift
//  mEatUp
//
//  Created by Maciej Plewko on 12.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class RoomListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var cloudKitHelper: CloudKitHelper?
    let sections = [SectionNames.MyRoom.rawValue, SectionNames.Joined.rawValue, SectionNames.Public.rawValue]
    
    var myRoom: Room?
    var joinedRooms: [Room]?
    var publicRooms: [Room]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cloudKitHelper = CloudKitHelper()
        createFakeData()
//      Method disabled due to lack of connection with CloudKit
//        loadDataFromCloudKit()
    }
    
    func createFakeData() {
        let user = User(fbID: "testfbid", name: "Pawel", surname: "K", photo: "asd")
        let restaurant = Restaurant(restaurantID: 1, name: "TestRest", address: "Asd")
        let room = Room(title: "test", accessType: .Public, restaurant: restaurant, maxCount: 5, date: NSDate(), owner: user)
//        room.roomID = 1
        
        cloudKitHelper?.saveUserRecord(user, completionHandler: nil, errorHandler: nil)
        cloudKitHelper?.saveRestaurantRecord(restaurant, completionHandler: nil, errorHandler: nil)
        cloudKitHelper?.saveRoomRecord(room, completionHandler: nil, errorHandler: nil)
    }
    
    func loadDataFromCloudKit() {
        cloudKitHelper?.loadPublicRoomRecords({
            rooms in
            self.publicRooms = rooms
            }, errorHandler: nil)
        
        cloudKitHelper?.loadInvitedRoomRecords("USERID PLACEHOLDER", completionHandler: {
            rooms in
            self.joinedRooms = rooms
            }, errorHandler: nil)
        
        cloudKitHelper?.loadUsersInRoomRecordWithUserId("USERID PLACEHOLDER", completionHandler: {
            userRooms in
            self.joinedRooms?.appendContentsOf(userRooms)
            }, errorHandler: nil)
        
        cloudKitHelper?.loadUserRoomRecord("USERID PLACEHOLDER", completionHandler: {
            room in
            self.myRoom = room
            }, errorHandler: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return myRoom != nil ? 1 : 0
        case 1:
            return joinedRooms?.count ?? 0
        default:
            return publicRooms?.count ?? 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
}
