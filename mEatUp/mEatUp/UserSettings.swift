//
//  UserSettings.swift
//  mEatUp
//
//  Created by Maciej Plewko on 13.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

class UserSettings: NSObject {
    
    let userDefaults = NSUserDefaults()
    
    // NSUserDefaults keys
    private let firstNameKey = "first_name"
    private let lastNameKey = "last_name"
    private let picutreURLKey = "picture_url"
    
    func saveUserDetails(firstName: String?, lastName: String?, pictureURL: String?) {
        userDefaults.setValue(firstName, forKey: firstNameKey)
        userDefaults.setValue(lastName, forKey: lastNameKey)
        userDefaults.setValue(pictureURL, forKey: picutreURLKey)
    }
    
    func firstName() -> String? {
        return userDefaults.stringForKey(firstNameKey)
    }
    
    func lastName() -> String? {
        return userDefaults.stringForKey(lastNameKey)
    }
    
    func pictureURL() -> String? {
        return userDefaults.stringForKey(picutreURLKey)
    }
}
