//
//  RoomListViewController.swift
//  mEatUp
//
//  Created by Maciej Plewko on 12.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import CloudKit
import FBSDKLoginKit

class RoomListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var roomTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var roomListLoader = RoomListDataLoader()
    let finishedRoomListLoader = FinishedRoomListDataLoader()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleManualRefresh(_:)), forControlEvents: .ValueChanged)
        return refreshControl
    }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    func setupView() {
        hideSearchBarScopes()
        roomTableView.addSubview(self.refreshControl)
        refreshControl.beginRefreshing()
        
        finishedRoomListLoader.loadUserRecordFromCloudKit()
        
        roomListLoader.completionHandler = {
            self.roomTableView.reloadData()
            self.showSearchBarScopes()
            self.refreshControl.endRefreshing()
        }
        
        roomListLoader.errorHandler = {
            self.roomTableView.reloadData()
            self.showSearchBarScopes()
            self.refreshControl.endRefreshing()
        }
        
        roomListLoader.loadUserRecordFromCloudKit()
        self.navigationController?.navigationBar.translucent = false
    }

    @IBAction func facebookLogout(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        if let loginView: LoginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController {
            FBSDKLoginManager().logOut()
            UserSettings().clearUserDetails()
            UIApplication.sharedApplication().keyWindow?.rootViewController = loginView
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomListLoader.currentRoomList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RoomListCell", forIndexPath: indexPath)
        
        if let cell = cell as? RoomListCell {
            let row = indexPath.row
            if let title = roomListLoader.currentRoomList[row].title, place = roomListLoader.currentRoomList[row].restaurant?.name, date = roomListLoader.currentRoomList[row].date {
                cell.setupCell(title, place: place, date: date)
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowRoomViewController", sender: roomListLoader.currentRoomList[indexPath.row])
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let scope = RoomDataScopes(rawValue: selectedScope) else {
            return
        }
        
        self.roomListLoader.dataScope = scope
        if let text = searchBar.text {
            setRoomFilter(text)
        }
        
        roomListLoader.completionHandler = {
            self.roomTableView.reloadData()
        }

        roomListLoader.loadCurrentRoomList(scope, filter: nil)
        
        roomTableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        guard let scope = RoomDataScopes(rawValue: searchBar.selectedScopeButtonIndex) else {
            return
        }
        setRoomFilter(searchText)
        self.roomListLoader.dataScope = scope

        
        self.roomTableView.reloadData()
    }
    
    func setRoomFilter(searchText: String) {
        if searchText.isEmpty {
            self.roomListLoader.filter = nil
        } else {
            self.roomListLoader.filter = { room in
                if let title = room.title {
                    return title.lowercaseString.containsString(searchText.lowercaseString)
                } else {
                    return false
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        guard let scope = RoomDataScopes(rawValue: searchBar.selectedScopeButtonIndex) else {
            return
        }
        
        searchBar.text = ""
        searchBar.endEditing(true)
        
        roomListLoader.loadCurrentRoomList(scope, filter: nil)
        
        self.roomTableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? RoomDetailsViewController {
            destination.userRecordID = roomListLoader.userRecordID
        }
        
        if let destination = segue.destinationViewController as? RoomViewController {
            destination.room = sender as? Room
            destination.userRecordID = roomListLoader.userRecordID
        }
    }
    
    private func hideSearchBarScopes() {
        searchBar.showsScopeBar = false;
        searchBar.sizeToFit()
    }
    
    private func showSearchBarScopes() {
        self.searchBar.showsScopeBar = true
        self.searchBar.sizeToFit()
    }
    
    func handleManualRefresh(refreshControl: UIRefreshControl) {
        roomListLoader.completionHandler = {
            self.roomTableView.reloadData()
            self.refreshControl.endRefreshing()
        }
        
        roomListLoader.loadUserRecordFromCloudKit()
    }
}
