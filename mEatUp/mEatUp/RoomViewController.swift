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
    @IBOutlet weak var chatTableView: UITableView!
    
    @IBOutlet weak var chatMessageTextField: UITextField!
    var chat: ChatLoader?

    var cloudKitHelper = CloudKitHelper()
    var room: Room?
    var userRecordID: CKRecordID?
    var roomDataLoader: RoomViewDataLoader?

    var viewPurpose: RoomViewPurpose?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleManualRefresh(_:)), forControlEvents: .ValueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        roomDataLoader?.loadUsers()
    }
    
    func setupViewController() {
        participantsTableView.addSubview(self.refreshControl)
        refreshControl.beginRefreshing()
        
        if let userRecordID = userRecordID, room = room {
            roomDataLoader = RoomViewDataLoader(userRecordID: userRecordID, room: room)
        }
        
        roomDataLoader?.refreshHandler = {
            self.participantsTableView.reloadData()
            self.refreshControl.endRefreshing()
        }
        
        roomDataLoader?.purposeHandler = {
            purpose in
            self.viewPurpose = purpose
            self.setupViewForPurpose(purpose)
        }
        
        roomDataLoader?.dismissHandler = {
            self.dismissViewControllerAnimated(true, completion: nil)
            let message = "A room that you were in was removed"
            AlertCreator.singleActionAlert("Info", message: message, actionTitle: "OK", actionHandler: nil)
        }
        
        if let room = room {
            infoView.startWithRoom(room)
        }
        infoView.singleTapAction = { [unowned self] in
            self.performSegueWithIdentifier("showRoomDetailsSegue", sender: nil)
        }
        
        if let roomRecordID = room?.recordID {
            chat = ChatLoader(roomRecordID: roomRecordID)
            chatTableView.delegate = chat
            chatTableView.dataSource = chat
            chat?.completionHandler = {
                self.chatTableView.reloadData()
            }
            chat?.loadChatMessages()
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
        if let navigationCtrl = segue.destinationViewController as? UINavigationController, let destination = navigationCtrl.topViewController as? InvitationViewController {
            destination.room = room
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
            pullAndStartRefreshingTableView()
            roomDataLoader?.leaveRoom(nil)
        case .User:
            pullAndStartRefreshingTableView()
            roomDataLoader?.joinRoom(nil)
        }
    }
    
    @IBAction func sendChatButtonPushed(sender: UIButton) {
        guard let roomRecordID = roomDataLoader?.room?.recordID, userRecordID = userRecordID else {
            // Alert - cant send message
            return
        }
        
        if let message = chatMessageTextField.text {
            let chatMessage = ChatMessage(roomRecordID: roomRecordID, userRecordID: userRecordID, message: message)
            chat?.sendChatMessage(chatMessage)
            chatMessageTextField.text = nil
        }
    }

}

extension RoomViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Participants"
    }

    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let inviteButton = UIButton(frame: CGRect(x: view.frame.width - view.frame.height, y: 0, width: view.frame.height, height: view.frame.height))
        inviteButton.setImage(UIImage(named: "AddUser.png"), forState: .Normal)
        inviteButton.addTarget(self, action: #selector(inviteButtonTapped), forControlEvents: .TouchUpInside)
        
        view.addSubview(inviteButton)
    }
    
    func inviteButtonTapped(sender: UIButton) {
        performSegueWithIdentifier("ShowInvitationRoomController", sender: nil)
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
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete, let roomRecordID = room?.recordID {
            roomDataLoader?.deleteUser(indexPath.row, roomRecordID: roomRecordID)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return viewPurpose == .Owner ? true : false
    }
    
    func handleManualRefresh(refreshControl: UIRefreshControl) {
        roomDataLoader?.loadUsers()
    }
    
    func pullAndStartRefreshingTableView() {
        let yOffset = participantsTableView.contentOffset.y - refreshControl.frame.size.height
        participantsTableView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: false)
        refreshControl.beginRefreshing()
    }
    
}
