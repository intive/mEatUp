//
//  UserWithStatus.swift
//  mEatUp
//
//  Created by Paweł Knuth on 04.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

class UserWithStatus: Equatable {
    var user: User?
    var status: ConfirmationStatus?
    
    init(user: User, status: ConfirmationStatus) {
        self.user = user
        self.status = status
    }
    
    init() {
    }
}

func == (lhs: UserWithStatus, rhs: UserWithStatus) -> Bool {
    return lhs.user == rhs.user
}
