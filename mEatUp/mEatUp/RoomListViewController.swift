//
//  RoomListViewController.swift
//  mEatUp
//
//  Created by Maciej Plewko on 12.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import CloudKit

class RoomListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var roomTableView: UITableView!
    
    var cloudKitHelper: CloudKitHelper?
    let sections = [SectionNames.MyRoom.rawValue, SectionNames.Joined.rawValue, SectionNames.Public.rawValue]
    
    var myRoom: Room?
    var joinedRooms: [Room] = []
    var publicRooms: [Room] = []
    
    var userRecordID: CKRecordID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cloudKitHelper = CloudKitHelper()
        createFakeData()
        loadDataFromCloudKit()
    }
    
    func createFakeData() {
        let user = User(fbID: "testfbid", name: "Pawel", surname: "K", photo: "asd")
        let restaurant = Restaurant(name: "TestRest", address: "Asd")
        let room = Room(title: "test", accessType: .Public, restaurant: restaurant, maxCount: 5, date: NSDate(), owner: user)
        
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        queue.addOperationWithBlock({
            self.cloudKitHelper?.saveUserRecord(user, completionHandler: nil, errorHandler: nil)
        })
        queue.addOperationWithBlock({
            self.cloudKitHelper?.saveRestaurantRecord(restaurant, completionHandler: nil, errorHandler: nil)
        })
        queue.addOperationWithBlock({
            self.cloudKitHelper?.saveRoomRecord(room, completionHandler: nil, errorHandler: nil)
        })
    }
    
    func loadDataFromCloudKit() {
        cloudKitHelper?.loadUserRecordWithFbId("testfbid", completionHandler: {
            userRecord in
                self.userRecordID = userRecord.recordID
        }, errorHandler: nil)
        
        cloudKitHelper?.loadPublicRoomRecords({
            rooms in
            dispatch_async(dispatch_get_main_queue(), {
                self.publicRooms = rooms
                self.roomTableView.reloadData()
            })
        }, errorHandler: nil)
        
        if let userRecordID = userRecordID {
            cloudKitHelper?.loadInvitedRoomRecords(userRecordID, completionHandler: {
                rooms in
                self.joinedRooms = rooms
            }, errorHandler: nil)
            
            cloudKitHelper?.loadUsersInRoomRecordWithUserId(userRecordID, completionHandler: {
                userRooms in
                self.joinedRooms.appendContentsOf(userRooms)
            }, errorHandler: nil)
        }
//        cloudKitHelper?.loadUserRoomRecord("USERID PLACEHOLDER", completionHandler: {
//            room in
//            self.myRoom = room
//            }, errorHandler: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return myRoom != nil ? 1 : 0
        case 1:
            return joinedRooms.count
        default:
            return publicRooms.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RoomListCell", forIndexPath: indexPath) as? RoomListCell
        if let title = publicRooms[indexPath.row].title {
            cell?.titleLabel.text = title
        }
        
        return cell!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
}
