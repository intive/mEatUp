//
//  NSDate+CompareExtension.swift
//  mEatUp
//
//  Created by Paweł Knuth on 25.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

extension NSDate {
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        return self.compare(dateToCompare) == NSComparisonResult.OrderedAscending ? true : false
    }
}
