//
//  ParticipantDebtCell.swift
//  mEatUp
//
//  Created by Maciej Plewko on 15.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class ParticipantDebtCell: UITableViewCell {
    
    @IBOutlet weak var participantLabel: UILabel!
    @IBOutlet weak var balanceTextField: UITextField!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    let imageDownloader = ImageDownloader()
    
    func configureWithParticipant(particpant: Participant) {
        participantLabel.text = "\(particpant.firstName) \(particpant.lastName)"
        balanceTextField.text = "\(particpant.debt.stringValue)"
        if let pictureURLString = particpant.pictureURL, url = NSURL(string: pictureURLString) {
            imageDownloader.setFacebookImageFromUrl(url, imageView: pictureImageView)
        }
    }
    
}