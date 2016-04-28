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
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    @IBOutlet weak var participantsTableView: UITableView!
    var cloudKitHelper = CloudKitHelper()
    var room: Room?
    var userRecordID: CKRecordID?
    
    var roomDataLoader: RoomViewDataLoader?
    
    var viewPurpose: RoomViewPurpose?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userRecordID = userRecordID, room = room {
            roomDataLoader = RoomViewDataLoader(userRecordID: userRecordID, room: room)
        }
        roomDataLoader?.refreshHandler = {
            self.participantsTableView.reloadData()
            self.loadingIndicator.stopAnimating()
        }
        
        roomDataLoader?.purposeHandler = {
            purpose in
            self.viewPurpose = purpose
            self.setupViewForPurpose(purpose)
        }
        
        roomDataLoader?.dismissHandler = {
            //alert about room removal you are currently in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        if let room = room {
            infoView.startWithRoom(room)
        }
        infoView.singleTapAction = { [unowned self] in
            self.performSegueWithIdentifier("showRoomDetailsSegue", sender: nil)
        }
        
        roomDataLoader?.determineViewPurpose()
    }

    func setupViewForPurpose(purpose: RoomViewPurpose) {
        guard let room = roomDataLoader?.room else {
            return
        }
        
        switch purpose {
        case .Owner:
            rightBarButton.title = room.eventOccured == true ? RoomViewActions.End.rawValue : RoomViewActions.Disband.rawValue
        case .Participant:
            rightBarButton.title = RoomViewActions.Leave.rawValue
            rightBarButton.enabled = !room.eventOccured
        case .User:
            rightBarButton.title = RoomViewActions.Join.rawValue
            rightBarButton.enabled = !room.eventOccured
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? RoomDetailsViewController {
            destination.room = room
            destination.userRecordID = userRecordID
        }
    }
    
    @IBAction func rightBarButtonPressed(sender: UIBarButtonItem) {
        guard let purpose = viewPurpose else {
            return
        }
        
        rightBarButton.enabled = false
        
        switch purpose {
        case .Owner:
            roomDataLoader?.room?.eventOccured == true ? roomDataLoader?.endRoom(nil, errorHandler: nil) : roomDataLoader?.disbandRoom(nil, errorHandler: nil)
            self.dismissViewControllerAnimated(true, completion: nil)
        case .Participant:
            roomDataLoader?.leaveRoom(nil)
        case .User:
            roomDataLoader?.joinRoom(nil)
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
            
        if let cell = cell as? RoomParticipantTableViewCell, let roomDataLoader = self.roomDataLoader {
            cell.configureWithRoom(roomDataLoader.users[indexPath.row])
            return cell
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let roomDataLoader = self.roomDataLoader else {
            return 0
        }
        
        return roomDataLoader.users.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
