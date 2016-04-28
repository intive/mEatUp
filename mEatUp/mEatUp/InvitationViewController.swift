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
    var filteredUsers = [User]()
    var checked = [CKRecordID]()
    var room: Room?
    
    
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
        guard let roomRecordID = room?.recordID else { return }
        for userRecordID in checked {
            let userInRoom = UserInRoom(userRecordID: userRecordID, roomRecordID: roomRecordID, confirmationStatus: .Invited)
            cloudKitHelper.saveUserInRoomRecord(userInRoom, completionHandler: nil, errorHandler: nil)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension InvitationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath)
        if let cell = cell as? UserTableViewCell {
            
            guard let userRecordID = users[indexPath.row].recordID else { return cell }
            let accessoryType: UITableViewCellAccessoryType = checked.contains(userRecordID) ? .Checkmark : .None
            cell.configureWithUser(users[indexPath.row], accessoryType: accessoryType)
            
            return cell
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)

        guard let userRecordID = users[indexPath.row].recordID else { return }
        
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
    
}
