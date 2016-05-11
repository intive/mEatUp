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

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    let userSettings = UserSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //configure loginButton appearance
        loginButton.layer.cornerRadius = 12
        loginButton.backgroundColor = UIColor.loginButtonBackgroundColor()
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.loginButtonBorderColor().CGColor
        loginButton.setTitleColor(UIColor.loginButtonTitleColorNormal(), forState: .Normal)
        loginButton.setTitleColor(UIColor.loginButtonTitleColorHighlited(), forState: .Highlighted)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if FBSDKAccessToken.currentAccessToken() != nil
        {
            createUser()
            loginButton.hidden = true
            performSegueWithIdentifier("ShowRoomListSegue", sender: nil)
        }
    }
    
    @IBAction func loginButtonClicked(sender: UIButton) {
        FBSDKLoginManager().logInWithReadPermissions(["public_profile"], fromViewController: self, handler: { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if (error == nil && result.grantedPermissions != nil){
                if(result.grantedPermissions.contains("public_profile"))
                {
                    self.createUser()
                }
            }

        })
    }
    
    func createUser() {
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
                    }, errorHandler: { error in
                            let newUser = User()
                            newUser.fbID = fbID
                            newUser.name = firstName
                            newUser.surname = lastName
                            newUser.photo = pictureURL
                            cloud.saveUserRecord(newUser, completionHandler: nil, errorHandler: nil)
                    })
                }
            }
        }
    }
    
}
