//
//  OnlyBottomBorderTextField.swift
//  mEatUp
//
//  Created by Krzysztof Przybysz on 13/04/16.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class UITextFieldMeatup: UITextField, UITextFieldDelegate {
    var maximumCharacters: Int = 20
    var delegate2: UITextFieldDelegate?
    
    override var delegate: UITextFieldDelegate? {
        get {
            return delegate2
        }
        set {
            if newValue as? UITextFieldMeatup != self {
                self.delegate2 = newValue
            } else {
                super.delegate = newValue
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: self.frame.size.height - 5, width: self.frame.size.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor.blackColor().CGColor
        self.layer.addSublayer(bottomBorder)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var returnValue = true
        let textFieldText: NSString = textField.text ?? ""
        let textAfterUpdate = textFieldText.stringByReplacingCharactersInRange(range, withString: string)
        if textAfterUpdate.characters.count > maximumCharacters {
            returnValue = false
        }
        return (delegate2?.textField?(textField, shouldChangeCharactersInRange: range, replacementString: string) ?? true) && returnValue
    }

}
