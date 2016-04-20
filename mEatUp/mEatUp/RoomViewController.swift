//
//  RoomViewController.swift
//  mEatUp
//
//  Created by Krzysztof Przybysz on 12/04/16.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import CloudKit

class RoomViewController: UIViewController {
    @IBOutlet weak var infoView: OscillatingRoomInfoView!
    
    @IBOutlet weak var participantsTableView: UITableView!
    var cloudKitHelper = CloudKitHelper()
    var room: Room?
    var users = [User]()
    var userRecordID: CKRecordID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let room = room {
            infoView.startWithRoom(room)
        }
        infoView.singleTapAction = { [unowned self] in
            self.performSegueWithIdentifier("showRoomDetailsSegue", sender: nil)
        }
        getUsers()
    }
    
    func getUsers() {
        if let room = room, recordID = room.recordID {
            cloudKitHelper.loadUsersInRoomRecordWithRoomId(recordID, completionHandler: { [weak self] user in
                self?.users.append(user)
                self?.participantsTableView.reloadData()
                }, errorHandler: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? RoomDetailsViewController {
            destination.room = room
            destination.userRecordID = userRecordID
        }
    }
    
}

extension RoomViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Participants"
        }
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCellWithIdentifier("ParticipantCell", forIndexPath: indexPath)
            
        if let cell = cell as? RoomParticipantTableViewCell {
            cell.configureWithRoom(users[indexPath.row])
            return cell
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
