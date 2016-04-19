//
//  FinishedRoomCell.swift
//  mEatUp
//
//  Created by Maciej Plewko on 14.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class FinishedRoomCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    func configureWithRoom(finishedRoom: FinishedRoom) {
        var balance: Double = 0.0
        if let participants = finishedRoom.participants {
            for participant in participants {
                if let participant = participant as? Participant {
                    balance = balance + participant.debt.doubleValue
                }
            }
        }
        
        titleLabel.text = finishedRoom.title
        balanceLabel.text = "\(balance)"
    }
    
}