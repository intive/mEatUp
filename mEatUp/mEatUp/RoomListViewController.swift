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
        loadUserRecordFromCloudKit()
    }
    
    func loadUserRecordFromCloudKit() {
        // testfbid is fbid placeholder and will be replaced by stored value
        cloudKitHelper?.loadUserRecordWithFbId("testfbid", completionHandler: {
            userRecord in
                self.userRecordID = userRecord.recordID
                self.loadRoomsForRoomList(userRecord.recordID!)
        }, errorHandler: nil)
    }
    
    func loadRoomsForRoomList(userRecordID: CKRecordID) {
        cloudKitHelper?.loadPublicRoomRecords({
            room in
                self.publicRooms.append(room)
                self.filterRooms()
            }, errorHandler: nil)


        cloudKitHelper?.loadInvitedRoomRecords(userRecordID, completionHandler: {
            room in
            if let room = room {
                self.joinedRooms.append(room)
                self.filterRooms()
            }
            }, errorHandler: nil)


        cloudKitHelper?.loadUsersInRoomRecordWithUserId(userRecordID, completionHandler: {
            userRoom in
            if let userRoom = userRoom {
                self.joinedRooms.append(userRoom)
                self.filterRooms()
            }
            }, errorHandler: nil)


        cloudKitHelper?.loadUserRoomRecord(userRecordID, completionHandler: {
            room in
                self.myRoom = room
                self.filterRooms()
            }, errorHandler: nil)
    }
    
    func filterRooms() {
        if joinedRooms.count != 0 {
            for room in joinedRooms {
                self.publicRooms = publicRooms.filter({$0.recordID?.recordName != room.recordID?.recordName })
            }
        }
        self.joinedRooms = joinedRooms.filter({ $0.recordID?.recordName != myRoom?.recordID?.recordName })
    
        self.roomTableView.reloadData()
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
        
        if let title = dataSource[indexPath.row].title {
            cell?.titleLabel.text = title
        }
        
        if let place = dataSource[indexPath.row].restaurant?.name {
            cell?.placeLabel.text = place
        }
        
        if let date = dataSource[indexPath.row].date {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .ShortStyle
            
            cell?.timeLabel.text = dateFormatter.stringFromDate(date)
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
