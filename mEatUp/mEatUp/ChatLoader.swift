//
//  ChatLoader.swift
//  mEatUp
//
//  Created by Paweł Knuth on 06.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class ChatLoader: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var messages = [ChatMessage]()
    
    var roomRecordID: CKRecordID?
    let cloudKitHelper = CloudKitHelper()
    
    var completionHandler: (() -> Void)?
    
    init(roomRecordID: CKRecordID) {
        super.init()
        self.roomRecordID = roomRecordID
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(chatMessageAddedNotification), name: "chatMessageAdded", object: nil)
    }
    
    func chatMessageAddedNotification(aNotification: NSNotification) {
        if let chatMessageRecordID = aNotification.object as? CKRecordID {
            cloudKitHelper.loadChatMessagesRecord(chatMessageRecordID, completionHandler: {
                chatMessage in
                if chatMessage.roomRecordID == self.roomRecordID {
                    guard let userRecordID = chatMessage.userRecordID else {
                        return
                    }
                    
                    self.cloudKitHelper.loadUserRecord(userRecordID, completionHandler: {
                        user in
                        chatMessage.user = user
                        self.messages.insert(chatMessage, atIndex: 0)
                        self.completionHandler?()
                        }, errorHandler: nil)
                }
                }, errorHandler: nil)
        }
    }
    
    func sendChatMessage(chatMessage: ChatMessage) {
        cloudKitHelper.saveChatRecord(chatMessage, completionHandler: {
            guard let userRecordID = chatMessage.userRecordID else {
                return
            }
            
            self.cloudKitHelper.loadUserRecord(userRecordID, completionHandler: {
                user in
                    chatMessage.user = user
                    self.messages.insert(chatMessage, atIndex: 0)
                    self.completionHandler?()
                }, errorHandler: nil)
        }, errorHandler: nil)
    }
    
    func loadChatMessages() {
        guard let roomRecordID = roomRecordID else {
            //Alert - chat couldn't load
            return
        }
        
        cloudKitHelper.loadChatMessagesRecordWithRoomId(roomRecordID, completionHandler: {
            messages in
            self.messages = messages
            for message in messages {
                guard let userRecordID = message.userRecordID else {
                    break
                }
                
                self.cloudKitHelper.loadUserRecord(userRecordID, completionHandler: {
                    user in
                        message.user = user
                        self.completionHandler?()
                }, errorHandler: nil)
            }
        }, errorHandler: nil)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatCell", forIndexPath: indexPath)
        
        if let cell = cell as? ChatCell {
            if let date = messages[indexPath.row].date, username = messages[indexPath.row].user?.username, message = messages[indexPath.row].message {
                cell.setupCell(date, username: username, message: message)
            }
            
            return cell
        }
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Chat"
    }
}
