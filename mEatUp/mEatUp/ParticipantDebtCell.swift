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
    var balanceIndicator: BalanceIndicator = .Neutral
    var participant: Participant!
    
    func configureWithParticipant(passedParticipant: Participant) {
        participant = passedParticipant
        participantLabel.text = "\(participant.firstName) \(participant.lastName)"
        balanceTextField.text = "\(abs(participant.debt.doubleValue))"
        
        setCellSettingsWithBalance(participant.debt.doubleValue)
        
        if let pictureURLString = participant.pictureURL, url = NSURL(string: pictureURLString) {
            pictureImageView.setFacebookImageFromUrl(url)
        }
    }
    
    @IBAction func balanceChanged(sender: UITextField) {
        if let cellText = balanceTextField.text, let newBalance = Double(cellText) {
            if newBalance != participant.debt.doubleValue {
                if balanceIndicator == .Negative {
                    participant.debt = -newBalance
                } else {
                    participant.debt = newBalance
                }
                setCellSettingsWithBalance(participant.debt.doubleValue)
            }
        }
    }
    
    @IBAction func balanceIndicatorChanged(sender: UIButton) {
        if let title = balanceIndicatorButton.titleLabel?.text {
            if participant.debt != 0.0 {
                if title == "+" {
                    balanceIndicatorButton.setTitle("-", forState: .Normal)
                    balanceTextField.backgroundColor = UIColor.redColor()
                    balanceIndicator = .Negative
                    participant.debt = -participant.debt.doubleValue
                } else {
                    balanceIndicatorButton.setTitle("+", forState: .Normal)
                    balanceTextField.backgroundColor = UIColor.greenColor()
                    balanceIndicator = .Positive
                    participant.debt = abs(participant.debt.doubleValue)
                }
            }
        }
    }
    
    func setCellSettingsWithBalance(balance: Double) {
        if balance < 0 {
            balanceTextField.backgroundColor = UIColor.redColor()
            balanceIndicatorButton.setTitle("-", forState: .Normal)
            balanceIndicator = .Negative
        } else if balance > 0 {
            balanceTextField.backgroundColor = UIColor.greenColor()
            balanceIndicatorButton.setTitle("+", forState: .Normal)
            balanceIndicator = .Positive
        } else {
            balanceTextField.backgroundColor = UIColor.whiteColor()
            balanceIndicatorButton.setTitle("+", forState: .Normal)
            balanceIndicator = .Neutral
        }
    }
    
}