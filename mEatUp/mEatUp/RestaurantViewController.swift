//
//  RestaurantViewController.swift
//  mEatUp
//
//  Created by Krzysztof Przybysz on 21/04/16.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class RestaurantViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    var cloudKitHelper = CloudKitHelper()
    var saveRestaurant: ((Restaurant) -> Void)?
    let stringLengthLimit = 30
    
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        if let name = nameTextField.text, let address = addressTextField.text {
            let restaurant = Restaurant(name: name, address: address)
            cloudKitHelper.saveRestaurantRecord(restaurant, completionHandler: {
                self.dismissViewControllerAnimated(true) { [unowned self] in
                     self.saveRestaurant?(restaurant)
                }
                }, errorHandler: nil)
        }
    }
}

extension RestaurantViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: NSString = textField.text ?? ""
        let textAfterUpdate = textFieldText.stringByReplacingCharactersInRange(range, withString: string)
        if textAfterUpdate.characters.count > stringLengthLimit {
            return false
        }
        return true
    }
}
