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
    
    @IBOutlet weak var tableView: UITableView!
    var participants: [Participant]!
    let ReuseIdentifierWebsiteCell = "ParticipantDebtCell"
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
}