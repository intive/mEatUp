//
//  DatePickerWithDoneButton.swift
//  mEatUp
//
//  Created by Krzysztof Przybysz on 14/04/16.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class DatePickerWithDoneButton: UIDatePicker {
    var doneTappedBlock: (NSDate -> ())?
    
    func toolBar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(doneTapped))
        
        toolBar.setItems([space, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        toolBar.sizeToFit()
        return toolBar
    }
    
    @objc private func doneTapped(sender: UIBarButtonItem) {
        doneTappedBlock?(date)
    }

}
