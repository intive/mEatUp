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
            if !name.isEmpty && !address.isEmpty {
                let restaurant = Restaurant(name: name, address: address)
                cloudKitHelper.saveRestaurantRecord(restaurant, completionHandler: {
                    self.dismissViewControllerAnimated(true) { [unowned self] in
                         self.saveRestaurant?(restaurant)
                    }
                    }, errorHandler: nil)
            } else {
                AlertCreator.singleActionAlert("Error", message: "Please fill all text fields.", actionTitle: "OK", actionHandler: nil)
            }
        }
    }
}

extension RestaurantViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
