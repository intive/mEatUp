//
//  RoomViewController.swift
//  mEatUp
//
//  Created by Krzysztof Przybysz on 12/04/16.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class RoomViewController: UIViewController {
    @IBOutlet weak var infoView: OscillatingRoomInfoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //added only for testing, needs to be deleted after adding CloudKit
        let room = createTemporaryRoom()
        infoView.startWithRoom(room)
        infoView.singleTapAction = { [unowned self] in
            self.performSegueWithIdentifier("showRoomDetailsSegue", sender: nil)
        }
    }
    
    //added only for testing, needs to be deleted after adding CloudKit
    func createTemporaryRoom() -> Room {
        let restaurant = Restaurant(name: "Bro Burgers", address: "Partyzantów 1, Szczecin")
        let user = User(fbID: "id", name: "Krzysztof", surname: "Przybysz", photo: "zzz")
        let room = Room(title: "My room", accessType: .Private, restaurant: restaurant, maxCount: 10, date: NSDate(), owner: user)
        return room
    }
}

extension RoomViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Participants"
        }
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ParticipantCell", forIndexPath: indexPath)
        return cell
    }
    
    //function added only to conform UITableViewDataSource protocol
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
}
