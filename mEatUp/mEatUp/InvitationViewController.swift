//
//  InvitationViewController.swift
//  mEatUp
//
//  Created by Krzysztof Przybysz on 27/04/16.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import CloudKit

class InvitationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let cloudKitHelper = CloudKitHelper()
    var users = [User]()
    var currentUserList: [User] {
        get {
            return loadCurrentUserList(filter)
        }
    }
    
    var filter: ((User) -> Bool)? = nil
    var checked = [CKRecordID]()
    var room: Room?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let roomRecordID = self.room?.recordID else { return }
        
        cloudKitHelper.loadUserRecords({ [unowned self] users in
            for user in users {
                guard let userRecordID = user.recordID else { return }
                self.cloudKitHelper.checkIfUserInRoom(roomRecordID, userRecordID: userRecordID, completionHandler: { [unowned self] userInRoom in
                    if userInRoom == nil {
                        self.users.append(user)
                        self.tableView.reloadData()
                    }
                    }, errorHandler: nil)
            }
            }, errorHandler: nil)
    }
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func inviteButtonTapped(sender: UIBarButtonItem) {
        //TUTAJ KRECIOLEK START
        sender.enabled = false
        guard let roomRecordID = room?.recordID else { return }
        for userRecordID in checked {
            let userInRoom = UserInRoom(userRecordID: userRecordID, roomRecordID: roomRecordID, confirmationStatus: .Invited)
            cloudKitHelper.saveUserInRoomRecord(userInRoom, completionHandler: {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))),
                    dispatch_get_main_queue(), {
                        //TUTAJ KRECIOLEK STOP
                        self.dismissViewControllerAnimated(true, completion: nil)
                })
            }, errorHandler: nil)
        }
    }
    
    func loadCurrentUserList(filter: ((User) -> Bool)?) -> [User] {
        guard let filter = filter else {
            return users
        }

        return users.filter({filter($0)})
    }
}

extension InvitationViewController: UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUserList.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath)
        if let cell = cell as? UserTableViewCell {
            
            guard let userRecordID = currentUserList[indexPath.row].recordID else { return cell }
            let accessoryType: UITableViewCellAccessoryType = checked.contains(userRecordID) ? .Checkmark : .None
            cell.configureWithUser(currentUserList[indexPath.row], accessoryType: accessoryType)
            
            return cell
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)

        guard let userRecordID = currentUserList[indexPath.row].recordID else { return }
        
        if checked.contains(userRecordID) {
            if let index = checked.indexOf(userRecordID) {
                checked.removeAtIndex(index)
                cell?.accessoryType = .None
            }
        } else {
            checked.append(userRecordID)
            cell?.accessoryType = .Checkmark
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filter = nil
        } else {
            filter = { user in
                guard let name = user.name, let surname = user.surname else {
                    return false
                }
                let userName = "\(name) \(surname)"
                return userName.lowercaseString.containsString(searchText.lowercaseString)
            }
        }
    
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        filter = nil
        searchBar.endEditing(true)
        
        tableView.reloadData()
    }
}
