//
//  LoginViewController.swift
//  mEatUp
//
//  Created by Maciej Plewko on 08.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    var userDefaults = NSUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureFacebook()
    }
    
    func configureFacebook() {
        loginButton.delegate = self;
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("Logged in")
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, picture.type(small)"]).startWithCompletionHandler { (connection, result, error) -> Void in
            
            let firstName: String? = (result.objectForKey("first_name") as? String)
            let lastName: String? = (result.objectForKey("last_name") as? String)
            let pictureURL: String? = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)
            
            self.userDefaults.setValue(firstName, forKey: "first_name")
            self.userDefaults.setValue(lastName, forKey: "last_name")
            self.userDefaults.setValue(pictureURL, forKey: "picture_url")
            
            print("Welcome, \(firstName) \(lastName) pictureURL: \(pictureURL)")
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("Logged out")
    }
    
}
