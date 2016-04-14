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
//        createFakeData()
        loadUserRecordFromCloudKit()
    }
    
    func createFakeData() {
        let user = User(fbID: "testfbid", name: "Pawel", surname: "K", photo: "asd")
        let restaurant = Restaurant(name: "TestRest", address: "Asd")
        let room = Room(title: "test", accessType: .Public, restaurant: restaurant, maxCount: 5, date: NSDate(), owner: user)
        let userInRoom = UserInRoom(user: user, room: room, confirmationStatus: .Accepted)
        
        self.cloudKitHelper?.saveUserRecord(user, completionHandler: {
            self.cloudKitHelper?.saveRestaurantRecord(restaurant, completionHandler: {
                self.cloudKitHelper?.saveRoomRecord(room, completionHandler: {
                    self.cloudKitHelper?.saveUserInRoomRecord(userInRoom, completionHandler: nil, errorHandler: nil)
                }, errorHandler: nil)
            }, errorHandler: nil)
        }, errorHandler: nil)
        
    }
    
    func loadUserRecordFromCloudKit() {
        cloudKitHelper?.loadUserRecordWithFbId("testfbid", completionHandler: {
            userRecord in
                self.userRecordID = userRecord.recordID
                self.loadDataFromCloudKit()
        }, errorHandler: nil)
    }
    
    func loadDataFromCloudKit() {
        if let userRecordID = userRecordID {
            cloudKitHelper?.loadRoomsForRoomList(userRecordID, completionHandler: {
                publicRooms, joinedRooms, myRoom in
                if joinedRooms.count != 0 {
                    for room in joinedRooms {
                        self.publicRooms = publicRooms.filter({ ($0.recordID?.isEqual(room.recordID))! })
                    }
                } else {
                    self.publicRooms = publicRooms
                }
                
                self.joinedRooms = joinedRooms.filter({ ($0.recordID?.isEqual(myRoom?.recordID))! })
                self.myRoom = myRoom
                
                self.roomTableView.reloadData()
                
            }, errorHandler: nil)
        }
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
        
        var dataSource: [Room] = []
        
        switch indexPath.section {
        case 0:
            if let myRoom = myRoom {
                dataSource.append(myRoom)
            }
        case 1:
            dataSource = joinedRooms
        default:
            dataSource = publicRooms
        }
        
        if let title = dataSource[indexPath.row].date {
            cell?.titleLabel.text = String(title)
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
