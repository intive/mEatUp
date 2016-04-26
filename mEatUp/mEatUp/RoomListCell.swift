//
//  RoomListCell.swift
//  mEatUp
//
//  Created by Paweł Knuth on 12.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import UIKit

class RoomListCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    let dateFormatter = NSDateFormatter()
    
    func setupCell(title: String, place: String, date: NSDate) {
        timeLabel.text = dateFormatter.stringFromDate(date, withFormat: "H:mm")
        dayLabel.text = dateFormatter.stringFromDate(date, withFormat: "dd.MM.yyyy")
        
        titleLabel.text = title
        placeLabel.text = place
    }
}
