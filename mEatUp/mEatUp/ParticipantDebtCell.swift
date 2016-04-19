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
    @IBOutlet weak var balanceIndicatorButton: UIButton!
    var balance: Double = 0.0
    
    let imageDownloader = ImageDownloader()
    
    func configureWithParticipant(particpant: Participant) {
        participantLabel.text = "\(particpant.firstName) \(particpant.lastName)"
        balanceTextField.text = "\(abs(particpant.debt.doubleValue))"
        
        balance = particpant.debt.doubleValue
        setColorWithBalance(balance)
        
        if let pictureURLString = particpant.pictureURL, url = NSURL(string: pictureURLString) {
            imageDownloader.setFacebookImageFromUrl(url, imageView: pictureImageView)
        }
    }
    
    @IBAction func balanceChanged(sender: UITextField) {
        if let cellText = balanceTextField.text, let newBalance = Double(cellText) {
            if newBalance != balance {
                balance = newBalance
                setColorWithBalance(balance)
            }
        }
    }
    
    @IBAction func balanceIndicatorChanged(sender: UIButton) {
        if let title = balanceIndicatorButton.titleLabel?.text {
            if balance != 0.0 {
                if title == "+" {
                    balanceIndicatorButton.setTitle("-", forState: .Normal)
                    balanceTextField.backgroundColor = UIColor.redColor()
                } else {
                    balanceIndicatorButton.setTitle("+", forState: .Normal)
                    balanceTextField.backgroundColor = UIColor.greenColor()
                }
            }
        }
    }
    
    func setColorWithBalance(balance: Double) {
        if balance < 0 {
            balanceTextField.backgroundColor = UIColor.redColor()
            balanceIndicatorButton.setTitle("-", forState: .Normal)
        } else if balance > 0 {
            balanceTextField.backgroundColor = UIColor.greenColor()
            balanceIndicatorButton.setTitle("+", forState: .Normal)
        } else {
            balanceTextField.backgroundColor = UIColor.whiteColor()
            balanceIndicatorButton.setTitle("+", forState: .Normal)
        }

    }
}