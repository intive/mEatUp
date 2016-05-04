//
//  NSArray+FindIndex.swift
//  mEatUp
//
//  Created by Paweł Knuth on 28.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    func findIndex(object: Element) -> Int? {
        for (index, element) in self.enumerate() {
            if element == object {
                return index
            }
        }
        return nil
    }
}
