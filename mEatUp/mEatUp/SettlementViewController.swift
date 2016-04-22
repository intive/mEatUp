//
//  SettlementViewController.swift
//  mEatUp
//
//  Created by Maciej Plewko on 13.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import CoreData

class SettlementViewController: UIViewController {
    
    @IBOutlet weak var infoView: OscillatingRoomInfoView!
    @IBOutlet weak var tableView: UITableView!
    //passed in PrepareForSegue method
    var participants: [Participant]!
    var finishedRoom: FinishedRoom!
    let room = Room()
    let ReuseIdentifierWebsiteCell = "ParticipantDebtCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        room.date = finishedRoom.date
        room.restaurant = Restaurant()
        room.restaurant?.name = finishedRoom.restaurant
        room.title = finishedRoom.title
        room.didEnd = true
        room.maxCount = 0
        room.accessType = AccessType(rawValue: AccessType.Public.rawValue)
        if let owner = finishedRoom.owner {
            let ownerData = owner.componentsSeparatedByString(" ")
            room.owner?.name = ownerData[0]
            room.owner?.surname = ownerData[1]
        }
        
        infoView.startWithRoom(room)
        infoView.singleTapAction = { [unowned self] in
            self.performSegueWithIdentifier("showRoomDetailsSegue", sender: nil)
        }

    }
    
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        CoreDataController.sharedInstance.saveContext()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? RoomDetailsViewController {
            destination.room = room
        }
    }
}

extension SettlementViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifierWebsiteCell, forIndexPath: indexPath)
        let participant = participants[indexPath.row]
        if let cell = cell as? ParticipantDebtCell {
            cell.configureWithParticipant(participant)
        }
 
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
