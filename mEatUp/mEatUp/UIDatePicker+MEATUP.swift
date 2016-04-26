//
//  DatePickerWithDoneButton.swift
//  mEatUp
//
//  Created by Krzysztof Przybysz on 14/04/16.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class UIDatePickerMeatup: UIDatePicker {
    var doneButtonAction: (NSDate -> ())?
    var cancelButtonAction: (() -> ())?
    
    func toolBar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        
        let cancel = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(cancelTapped))
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(doneTapped))
        
        toolBar.setItems([cancel, space, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        toolBar.sizeToFit()
        return toolBar
    }
    
    @objc private func doneTapped(sender: UIBarButtonItem) {
        doneButtonAction?(date)
    }
    
    @objc private func cancelTapped(sender: UIBarButtonItem) {
        cancelButtonAction?()
    }

}
