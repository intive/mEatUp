//
//  ChatCell.swift
//  mEatUp
//
//  Created by Paweł Knuth on 05.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import UIKit

class ChatCell: UITableViewCell {

    let dateFormatter = NSDateFormatter()
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    func setupCell(date: NSDate, username: String, message: String) {
//        timeLabel.text = dateFormatter.stringFromDate(date, withFormat: "H:mm")
//        dayLabel.text = dateFormatter.stringFromDate(date, withFormat: "dd.MM.yyyy")
        dateLabel.text = dateFormatter.stringFromDate(date, withFormat: "H:mm")
        messageLabel.text = message
        usernameLabel.text = username
    }
}
