//
//  RoomViewController.swift
//  mEatUp
//
//  Created by Krzysztof Przybysz on 12/04/16.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import CloudKit

class RoomViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var infoView: OscillatingRoomInfoView!
    @IBOutlet weak var participantsTableView: UITableView!
    @IBOutlet weak var chatTableView: UITableView!
    
    @IBOutlet weak var chatMessageTextField: UITextField!
    var chat: ChatLoader?
    
    var cloudKitHelper = CloudKitHelper()
    var room: Room?
    var userRecordID: CKRecordID?
    var roomDataLoader: RoomViewDataLoader?

    var viewPurpose: RoomViewPurpose?
    
    @IBOutlet weak var bottomButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomChatTextConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatMinHeight: NSLayoutConstraint!
    @IBOutlet weak var participantsMaxHeight: NSLayoutConstraint!
    @IBOutlet weak var participantsMinHeight: NSLayoutConstraint!
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleManualRefresh(_:)), forControlEvents: .ValueChanged)
        return refreshControl
    }()
        
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupViewController()
        roomDataLoader?.loadUsers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        registerForKeyboardNotifications()
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
            message in
            self.dismissViewControllerAnimated(true, completion: {
                if !message.isEmpty {
                    AlertCreator.singleActionAlert("Info", message: message, actionTitle: "OK", actionHandler: nil)
                }
            })
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
                self.scrollChatTableViewToLatestMessage()
            }
            chat?.loadChatMessages()
        }
        
        roomDataLoader?.determineViewPurpose()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        roomDataLoader?.removeNotifications()
    }
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillBeHidden), name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWasShown), name: UIKeyboardDidShowNotification, object: nil)
    }
    
    func keyboardWasShown(aNotification: NSNotification) {
        let info = aNotification.userInfo
        
        if let keyboardSize = (info?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            chatMinHeight.constant = calculateChatHeight(keyboardSize.height)
            chatMinHeight.priority = 999
            participantsMaxHeight.priority = 250
            participantsMinHeight.priority = 999
            bottomButtonConstraint.priority = 250
            bottomChatTextConstraint.priority = 250
            UIView.animateWithDuration(0.5, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillBeHidden(aNotification: NSNotification) {
        bottomButtonConstraint.priority = 999
        bottomChatTextConstraint.priority = 999
        chatMinHeight.priority = 250
        participantsMinHeight.priority = 250
        participantsMaxHeight.priority = 999
        UIView.animateWithDuration(0.5, animations: {
            self.view.layoutIfNeeded()
            } ,completion: { bool in
                self.scrollChatTableViewToLatestMessage()
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func calculateChatHeight(keyboardHeight: CGFloat) -> CGFloat {
        return view.frame.height - keyboardHeight - chatMessageTextField.frame.height - 15
    }
    
    func scrollChatTableViewToLatestMessage() {
        guard let messagesCount = self.chat?.messages.count else {
            return
        }
        
        if messagesCount > 0 {
            let path = NSIndexPath(forRow: messagesCount - 1, inSection: 0)
            self.chatTableView.scrollToRowAtIndexPath(path, atScrollPosition: .Bottom, animated: true)
        }
    }

    func setupViewForPurpose(purpose: RoomViewPurpose) {
        guard let room = roomDataLoader?.room else {
            return
        }
        
        var enabled = true
        var title = ""
        
        switch purpose {
        case .Owner:
            title = room.eventOccured == true ? RoomViewActions.End.rawValue : RoomViewActions.Disband.rawValue
        case .Participant:
            title = RoomViewActions.Leave.rawValue
            enabled = !room.eventOccured
        case .User:
            title = RoomViewActions.Join.rawValue
            enabled = !room.eventOccured
        }
        
        let rightBarButton = UIBarButtonItem(title: title, style: .Bordered, target: self, action: "rightBarButtonPressed:")
        rightBarButton.enabled = enabled
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? RoomDetailsViewController {
            destination.room = room
            destination.userRecordID = userRecordID
        }
        if let navigationCtrl = segue.destinationViewController as? UINavigationController, let destination = navigationCtrl.topViewController as? InvitationViewController {
            destination.room = room
            destination.completionHandler = {
                user in
                let invitedUser = UserWithStatus(user: user, status: .Invited)
                self.roomDataLoader?.users.append(invitedUser)
                self.participantsTableView.reloadData()
            }
        }
    }
    
    func rightBarButtonPressed(sender: UIBarButtonItem) {
        guard let purpose = viewPurpose else {
            return
        }
        
        sender.enabled = false
        
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
            AlertCreator.singleActionAlert("Error", message: "Could not send message.", actionTitle: "OK", actionHandler: nil)
            return
        }
        
        if let message = chatMessageTextField.text {
            if message.isEmpty {
                return
            }
            
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
        if viewPurpose == .Owner {
            let inviteButton = UIButton(frame: CGRect(x: view.frame.width - view.frame.height, y: 0, width: view.frame.height, height: view.frame.height))
            inviteButton.setImage(UIImage(named: "AddUser.png"), forState: .Normal)
            inviteButton.addTarget(self, action: #selector(inviteButtonTapped), forControlEvents: .TouchUpInside)
            
            view.addSubview(inviteButton)
        }
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
        guard let selectedUser = roomDataLoader?.users[indexPath.row].user else {
            return false
        }
        return (viewPurpose == .Owner && selectedUser.recordID != userRecordID) ? true : false
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
