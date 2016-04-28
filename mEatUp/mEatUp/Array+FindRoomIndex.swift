//
//  NSArray+FindAndReplace.swift
//  mEatUp
//
//  Created by Paweł Knuth on 28.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

extension Array {
    func findRoomIndex(room: Room) -> Int? {
        for (index, element) in self.enumerate() {
            if let element = element as? Room {
                if element == room {
                    return index
                }
            }
        }
        return nil
    }
}
