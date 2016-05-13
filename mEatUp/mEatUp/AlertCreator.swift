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
        })
        alert.addAction(action)
        alert.show(true)
    }
    
    static public func confirmationAlert(title: String, message: String, yesActionHandler: (() -> Void)?, noActionHandler: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .Default, handler: { (_) -> Void in
            yesActionHandler?()
        })
        
        let noAction = UIAlertAction(title: "No", style: .Default, handler: { (_) -> Void in
            noActionHandler?()
        })
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        alert.show(true)
    }
}
