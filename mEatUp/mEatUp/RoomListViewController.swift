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
    
    var roomListLoader = RoomListDataLoader()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roomListLoader.completionHandler = { self.roomTableView.reloadData() }
        roomListLoader.loadUserRecordFromCloudKit()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return roomListLoader.myRoom != nil ? 1 : 0
        case 1:
            return roomListLoader.joinedRooms.count
        default:
            return roomListLoader.publicRooms.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RoomListCell", forIndexPath: indexPath)
        
        var dataSource: [Room] = []
        
        switch indexPath.section {
        case 0:
            if let myRoom = roomListLoader.myRoom {
                dataSource.append(myRoom)
            }
        case 1:
            dataSource = roomListLoader.joinedRooms
        default:
            dataSource = roomListLoader.publicRooms
        }
        
        if let cell = cell as? RoomListCell {
            if let title = dataSource[indexPath.row].title, place = dataSource[indexPath.row].restaurant?.name, date = dataSource[indexPath.row].date {
                cell.setupCell(title, place: place, date: date)
            }
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return roomListLoader.sections.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return roomListLoader.sections[section]
    }
}