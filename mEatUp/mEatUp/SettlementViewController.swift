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
    //passed in PrepareForSegue method
    var participants: [Participant]!
    //passed in PrepareForSegue method
    var coreDataController : CoreDataController!
    let ReuseIdentifierWebsiteCell = "ParticipantDebtCell"
    
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        for i in 0 ..< participants.count {
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0))  as? ParticipantDebtCell {
                if let cellText = cell.balanceTextField.text, var balance = Double(cellText), let color = cell.balanceTextField.backgroundColor {
                    if color == UIColor.redColor() {
                        balance = -balance
                    }
                    participants[i].setValue(balance, forKey: "debt")
                }
            }
        }
        coreDataController.saveContext()
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
}