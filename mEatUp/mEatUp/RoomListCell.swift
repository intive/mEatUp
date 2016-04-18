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
    @IBOutlet weak var timeLabel: UILabel!
    
    let dateFormatter = NSDateFormatter()
    
    func setupCell(title: String, place: String, date: NSDate) {
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        
        titleLabel.text = title
        placeLabel.text = place
        timeLabel.text = dateFormatter.stringFromDate(date)
    }
}
