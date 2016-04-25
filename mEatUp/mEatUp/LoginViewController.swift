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

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    let userSettings = UserSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFacebook()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if FBSDKAccessToken.currentAccessToken() != nil
        {
            loginButton.hidden = true
            performSegueWithIdentifier("ShowRoomListSegue", sender: nil)
        }
    }
    
    func configureFacebook() {
        loginButton.delegate = self
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil {
        } else {
            FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"id, first_name, last_name, picture.type(small)"]).startWithCompletionHandler { (connection, result, error) -> Void in
                if error != nil {
                } else {
                    if let fbID = (result.objectForKey("id") as? String) {
                        let firstName: String? = (result.objectForKey("first_name") as? String)
                        let lastName: String? = (result.objectForKey("last_name") as? String)
                        let pictureURL: String? = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)
                    
                        self.userSettings.saveUserDetails(fbID, firstName: firstName, lastName: lastName, pictureURL: pictureURL)
                    
                        let cloud = CloudKitHelper()
                        cloud.loadUserRecordWithFbId(fbID, completionHandler: { user in
                            if user.recordID == nil {
                                let newUser = User()
                                newUser.fbID = fbID
                                newUser.name = firstName
                                newUser.surname = lastName
                                newUser.photo = pictureURL
                                cloud.saveUserRecord(newUser, completionHandler: nil, errorHandler: nil)
                            }
                        }, errorHandler: nil)
                    }
                }
            }
        }
    }
    
    //function added only to conform FBSDKLoginButtonDelegate protocol
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {

    }
    
}
