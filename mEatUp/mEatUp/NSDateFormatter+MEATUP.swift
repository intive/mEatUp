//
//  NSDateFormatter+MEATUP.swift
//  mEatUp
//
//  Created by Krzysztof Przybysz on 18/04/16.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

extension NSDateFormatter {
    func stringFromDate(date: NSDate, withFormat format: String) -> String {
        let oldDateFormat = self.dateFormat
        self.dateFormat = format
        let toReturn = self.stringFromDate(date)
        self.dateFormat = oldDateFormat
        return toReturn
    }
}
