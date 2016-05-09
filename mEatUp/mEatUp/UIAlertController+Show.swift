//
//  UIAlertController+Show.swift
//  mEatUp
//
//  Created by Maciej Plewko on 06.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    func show(animated: Bool) {
        if let window = UIApplication.sharedApplication().keyWindow {
            var viewController = window.rootViewController
            while viewController?.presentedViewController != nil {
                viewController = viewController?.presentedViewController
            }
            viewController?.presentViewController(self, animated: true, completion: nil)
        }
    }
    
}
