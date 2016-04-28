//
//  UserTableViewCell.swift
//  mEatUp
//
//  Created by Krzysztof Przybysz on 27/04/16.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    var marked = false
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureWithUser(user: User, accessoryType: UITableViewCellAccessoryType) {
        if let name = user.name, let surname = user.surname {
            nameLabel.text = "\(name) \(surname)"
        }
        if let URLasString = user.photo, let url = NSURL(string: URLasString) {
            imgView.setImageFromUrl(url)
        }
        self.accessoryType = accessoryType
    }
}
