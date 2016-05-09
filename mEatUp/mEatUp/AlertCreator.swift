//
//  AlertCreator.swift
//  mEatUp
//
//  Created by Maciej Plewko on 05.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

public class AlertCreator {
   
    static public func singleActionAlert(title: String, message: String, actionTitle: String, actionHandler: ((UIAlertController) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: actionTitle, style: .Default, handler: { (_) -> Void in
            actionHandler?(alert)
            print("OK")
        })
        alert.addAction(action)
        alert.show(true)
    }
    
}
