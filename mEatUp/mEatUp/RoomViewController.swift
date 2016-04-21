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
    
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    @IBOutlet weak var participantsTableView: UITableView!
    var cloudKitHelper = CloudKitHelper()
    var room: Room?
    var users = [User]()
    var userRecordID: CKRecordID?
    
    var viewPurpose: RoomViewPurpose?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let room = room {
            infoView.startWithRoom(room)
        }
        infoView.singleTapAction = { [unowned self] in
            self.performSegueWithIdentifier("showRoomDetailsSegue", sender: nil)
        }
        determineViewPurpose()
    }
    
    func getUsers() {
        if let roomRecordID = room?.recordID {
            cloudKitHelper.loadUsersInRoomRecordWithRoomId(roomRecordID, completionHandler: { [weak self] user in
                self?.users.append(user)
                self?.participantsTableView.reloadData()
            }, errorHandler: nil)
        }
    }
    
    func determineViewPurpose() {
        if let userRecordID = userRecordID, roomRecordID = room?.recordID {
            cloudKitHelper.checkIfUserInRoom(roomRecordID, userRecordID: userRecordID, completionHandler: {
                inRoom in
                    if inRoom {
                        if self.room?.owner?.recordID == userRecordID {
                            self.viewPurpose = RoomViewPurpose.Owner
                        } else {
                            self.viewPurpose = RoomViewPurpose.Participant
                        }
                    } else {
                        self.viewPurpose = RoomViewPurpose.User
                    }
                    if let viewPurpose = self.viewPurpose {
                        self.setupViewForPurpose(viewPurpose)
                    }
                    self.getUsers()
            }, errorHandler: nil)
        }
    }
    
    func setupViewForPurpose(purpose: RoomViewPurpose) {
        switch purpose {
        case .Owner:
            rightBarButton.title = RoomViewActions.Delete.rawValue
        case .Participant:
            rightBarButton.title = RoomViewActions.Leave.rawValue
        case .User:
            rightBarButton.title = RoomViewActions.Join.rawValue
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
