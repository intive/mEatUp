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
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var roomListLoader = RoomListDataLoader()
    let finishedRoomListLoader = FinishedRoomListDataLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideSearchBarScopes()
        
        roomListLoader.completionHandler = {
            self.roomTableView.reloadData()
            self.roomListLoader.currentRoomList = self.roomListLoader.publicRooms
            self.loadingIndicator.stopAnimating()
            self.showSearchBarScopes()
        }
        roomListLoader.loadUserRecordFromCloudKit()
        self.navigationController?.navigationBar.translucent = false
        finishedRoomListLoader.loadUserRecordFromCloudKit()

        if let didDetectIncompatibleStore = UserSettings().incompatibleStoreDetection where didDetectIncompatibleStore == true {
            let applicationName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleDisplayName")
            let message = "A serious application error occurred while \(applicationName) tried to read your data. Please contact support for help."
            
            self.showAlertWithTitle("Warning", message: message, cancelButtonTitle: "OK")
        }
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
        
        roomListLoader.completionHandler = {
            self.roomTableView.reloadData()
            self.loadingIndicator.stopAnimating()
        }
        roomListLoader.loadCurrentRoomList(scope, filter: nil)
        
        roomTableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        guard let scope = RoomDataScopes(rawValue: searchBar.selectedScopeButtonIndex) else {
            return
        }
        
        if searchText.isEmpty {
            roomListLoader.loadCurrentRoomList(scope, filter: nil)
        } else {
            roomListLoader.loadCurrentRoomList(scope, filter: {room in
                if let title = room.title {
                    return title.lowercaseString.containsString(searchText.lowercaseString)
                } else {
                    return false
                }
            })
        }
        
        self.roomTableView.reloadData()
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
    
    private func showAlertWithTitle(title: String, message: String, cancelButtonTitle: String) {
        // Initialize Alert Controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Configure Alert Controller
        alertController.addAction(UIAlertAction(title: cancelButtonTitle, style: .Default, handler: { (_) -> Void in
            UserSettings().incompatibleStoreDetection = false
        }))
        
        // Present Alert Controller
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func hideSearchBarScopes() {
        searchBar.showsScopeBar = false;
        searchBar.sizeToFit()
    }
    
    private func showSearchBarScopes() {
        self.searchBar.showsScopeBar = true
        self.searchBar.sizeToFit()
    }
}
