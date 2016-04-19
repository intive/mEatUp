//
//  RoomDetailsViewController.swift
//  mEatUp
//
//  Created by Krzysztof Przybysz on 13/04/16.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class RoomDetailsViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var ownerTextField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var hourTextField: UITextField!
    @IBOutlet weak var limitSlider: UISlider!
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var privateSwitch: UISwitch!
    
    var activeField: UITextField?
    var room: Room?
    var restaurants = [Restaurant]()
    let datePicker = DatePickerWithDoneButton()
    let formatter = NSDateFormatter()
    let cloudKitHelper = CloudKitHelper()
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        limitLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func placeTextFieldEditing(sender: UITextField) {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        sender.inputView = picker
    }
    
    @IBAction func dateTextFieldEditing(sender: UITextField) {
        datePicker.date = NSDate()
        datePicker.datePickerMode = .Date
        
        sender.inputAccessoryView = datePicker.toolBar()
        datePicker.doneTappedBlock = { [weak self] date in
            self?.dateTextField.text = self?.formatter.stringFromDate(date, withFormat: "dd.MM.yyyy")
            self?.view.endEditing(true)
        }
        sender.inputView = datePicker
    }
    
    @IBAction func hourTextFieldEditing(sender: UITextField) {
        datePicker.datePickerMode = .Time
        
        sender.inputAccessoryView = datePicker.toolBar()
        datePicker.doneTappedBlock = { [weak self] date in
            self?.hourTextField.text = self?.formatter.stringFromDate(date, withFormat: "H:mm")
            self?.view.endEditing(true)
        }
        sender.inputView = datePicker
    }
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillBeHidden), name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWasShown), name: UIKeyboardDidShowNotification, object: nil)
    }
    
    func keyboardWasShown(aNotification: NSNotification) {
        let info = aNotification.userInfo
        
        if let keyboardSize = (info?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            
            var aRect = self.view.frame
            aRect.size.height -= keyboardSize.height
            if let activeFieldFrame = activeField?.frame {
                if CGRectContainsPoint(aRect, activeFieldFrame.origin) {
                    scrollView.scrollRectToVisible(activeFieldFrame, animated: true)
                }
            }
        }
    }
    
    func keyboardWillBeHidden(aNotification: NSNotification) {
        let contentInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //added only for testing, needs to be deleted after adding CloudKit
        room = createTemporaryRoom()
        if let room = room {
            configureWithRoom(room)
        }
        //hardcoded bool just for testing, needs to be determined based on if the visiting user is the room's owner
        enableUserInteraction(true)
        
        limitLabel.text = "\(room?.maxCount ?? 0)"
        datePicker.locale = NSLocale(localeIdentifier: "PL")
        registerForKeyboardNotifications()
        self.navigationController?.navigationBar.translucent = false;
//        getRestaurants()
        
        cloudKitHelper.loadUserRecords({
            user in
                print(user)
            }, errorHandler: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func getRestaurants() {
        cloudKitHelper.loadRestaurantRecords({ [weak self] restaurants in
            print(restaurants)
            self?.restaurants.appendContentsOf(restaurants)
            }, errorHandler: nil)
    }
    
    func enableUserInteraction(bool: Bool) {
        ownerTextField.userInteractionEnabled = false
        placeTextField.userInteractionEnabled = bool
        dateTextField.userInteractionEnabled = bool
        hourTextField.userInteractionEnabled = bool
        limitSlider.userInteractionEnabled = bool
        privateSwitch.userInteractionEnabled = bool
        saveButton.hidden = !bool
    }
    
    func configureWithRoom(room: Room) {
        title = "\(room.title ?? "Room") Details"
        
        if let name = room.owner?.name, let surname = room.owner?.surname, let date = room.date, let limit = room.maxCount, let access = room.accessType?.rawValue {
            ownerTextField.text = "\(name) \(surname)"
            placeTextField.text = room.restaurant?.name
            hourTextField.text = formatter.stringFromDate(date, withFormat: "H:mm")
            dateTextField.text = formatter.stringFromDate(date, withFormat: "dd.MM.yyyy")
            limitSlider.value = Float(limit)
            privateSwitch.on = access == 1 ? true : false
        }
    }
    
    //added only for testing, needs to be deleted after adding CloudKit
    func createTemporaryRoom() -> Room {
        let restaurant = Restaurant(name: "Bro Burgers", address: "Partyzantów 1, Szczecin")
        let user = User(fbID: "id", name: "Krzysztof", surname: "Przybysz", photo: "zzz")
        let room = Room(title: "My room", accessType: .Private, restaurant: restaurant, maxCount: 10, date: NSDate(), owner: user)
        return room
    }
    
}

extension RoomDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == hourTextField || textField == dateTextField || textField == ownerTextField || textField == placeTextField {
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
    }
}

extension RoomDetailsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return restaurants.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return restaurants[row].name
    }
}
