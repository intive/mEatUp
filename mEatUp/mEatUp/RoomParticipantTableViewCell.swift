//
//  RoomParticipantTableViewCell.swift
//  mEatUp
//
//  Created by Krzysztof Przybysz on 19/04/16.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class RoomParticipantTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var invitedImageView: UIImageView!
    
    func configureWithRoom(userWithStatus: UserWithStatus) {
        guard let user = userWithStatus.user, status = userWithStatus.status else {
            return
        }
        
        self.backgroundColor = status == .Invited ? UIColor.silverSandColor() : nil
        invitedImageView.image = status == .Invited ? UIImage(named: "Invited") : nil
        
        nameLabel.text = "\(user.name ?? "") \(user.surname ?? "")"
        if let URLasString = user.photo, let url = NSURL(string: URLasString) {
            imgView.setImageFromUrl(url)
        }
    }

}
