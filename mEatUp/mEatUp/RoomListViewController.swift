//
//  RoomListViewController.swift
//  mEatUp
//
//  Created by Maciej Plewko on 12.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import CloudKit

class RoomListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var roomTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var roomListLoader = RoomListDataLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roomListLoader.completionHandler = {
            self.roomTableView.reloadData()
            self.roomListLoader.currentRoomList = self.roomListLoader.publicRooms
        }
        roomListLoader.loadUserRecordFromCloudKit()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomListLoader.currentRoomList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RoomListCell", forIndexPath: indexPath)
        
        if let cell = cell as? RoomListCell {
            if let title = roomListLoader.currentRoomList[indexPath.row].title, place = roomListLoader.currentRoomList[indexPath.row].restaurant?.name, date = roomListLoader.currentRoomList[indexPath.row].date {
                cell.setupCell(title, place: place, date: date)
            }
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        roomListLoader.completionHandler = {
            self.roomTableView.reloadData()
        }
        roomListLoader.loadCurrentRoomList(selectedScope, filter: nil)
        
        roomTableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            roomListLoader.loadCurrentRoomList(searchBar.selectedScopeButtonIndex, filter: nil)
        } else {
            roomListLoader.loadCurrentRoomList(searchBar.selectedScopeButtonIndex, filter: {room in
                return room.title!.lowercaseString.containsString(searchText.lowercaseString)})
        }
        
        self.roomTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        
        roomListLoader.loadCurrentRoomList(searchBar.selectedScopeButtonIndex, filter: nil)
        
        self.roomTableView.reloadData()
    }
}