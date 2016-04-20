//
//  OnlyBottomBorderTextField.swift
//  mEatUp
//
//  Created by Krzysztof Przybysz on 13/04/16.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class OnlyBottomBorderTextField: UITextField {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: self.frame.size.height - 5, width: self.frame.size.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor.blackColor().CGColor
        self.layer.addSublayer(bottomBorder)
    }

}
