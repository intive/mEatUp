//
//  UISearchController+MEATUP.swift
//  mEatUp
//
//  Created by Krzysztof Przybysz on 22/04/16.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

extension UISearchController {
    func gotContentAndActive() -> Bool {
        return self.active && self.searchBar.text != ""
    }
}
