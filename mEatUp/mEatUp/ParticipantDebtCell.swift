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
    let balancePattern = "^[0-9]+\\.?[0-9]{0,2}$"
    var balanceIndicator: BalanceIndicator = .Neutral
    var participant: Participant?
    var lastAcceptedBalance: String = "00.00"
    
    func configureWithParticipant(passedParticipant: Participant) {
        participant = passedParticipant
        if let participant = participant{
            participantLabel.text = "\(participant.firstName) \(participant.lastName)"
            balanceTextField.text = "\(abs(participant.debt.doubleValue))"
        
            setCellSettingsWithBalance(participant.debt.doubleValue)
        
            if let pictureURLString = participant.pictureURL, url = NSURL(string: pictureURLString) {
                pictureImageView.setImageFromUrl(url)
            }
        }
    }
    
    @IBAction func balanceChanged(sender: UITextField) {
        if let cellText = balanceTextField.text, let newBalance = Double(cellText), participant = participant {
            if cellText.rangeOfString(balancePattern, options: NSStringCompareOptions.RegularExpressionSearch) != nil {
                if newBalance != participant.debt.doubleValue {
                    lastAcceptedBalance = cellText
                    if balanceIndicator == .Negative {
                        participant.debt = -newBalance
                    } else {
                        participant.debt = newBalance
                    }
                    setCellSettingsWithBalance(participant.debt.doubleValue)
                }
            } else {
                AlertCreator.singleActionAlert("Wrong Quote", message: "Settlement quote can not contain more than two decimal places. \nExample: 0.00", actionTitle: "OK", actionHandler: nil)
                balanceTextField.text = lastAcceptedBalance
            }
        }
    }
    
    @IBAction func balanceIndicatorChanged(sender: UIButton) {
        if let title = balanceIndicatorButton.titleLabel?.text, participant = participant {
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
            balanceIndicatorButton.setTitle("+/-", forState: .Normal)
            balanceIndicator = .Neutral
        }
    }

}
