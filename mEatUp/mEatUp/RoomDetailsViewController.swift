//
//  RoomDetailsViewController.swift
//  mEatUp
//
//  Created by Krzysztof Przybysz on 13/04/16.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import CloudKit

class RoomDetailsViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ownerTextField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var hourTextField: UITextField!
    @IBOutlet weak var limitSlider: UISlider!
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var privateSwitch: UISwitch!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    
    var activeField: UITextField?
    var room: Room?
    var restaurants = [Restaurant]()
    let datePicker = DatePickerWithDoneButton()
    let formatter = NSDateFormatter()
    let picker = PickerViewMeatup()
    
    let cloudKitHelper = CloudKitHelper()
    
    var viewPurpose: RoomDetailsPurpose?
    var userRecordID: CKRecordID?
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        limitLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func placeTextFieldEditing(sender: UITextField) {
        picker.dataSource = self
        picker.delegate = self
        sender.inputView = picker
        
        picker.doneTappedBlock = { [weak self] in
            if let row = self?.picker.selectedRowInComponent(0) {
                self?.placeTextField.text = self?.restaurants[row].name
                self?.view.endEditing(true)
            }
        }
        sender.inputAccessoryView = picker.toolBar()
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
        
        if let purpose = viewPurpose {
            setupViewForPurpose(purpose)
        }
        
        //hardcoded bool just for testing, needs to be determined based on if the visiting user is the room's owner
        enableUserInteraction(true)
        
        limitLabel.text = "\(room?.maxCount ?? 0)"
        datePicker.locale = NSLocale(localeIdentifier: "PL")
        registerForKeyboardNotifications()
        self.navigationController?.navigationBar.translucent = false;
        getRestaurants()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupViewForPurpose(purpose: RoomDetailsPurpose) {
        switch purpose {
        case .Create:
            rightBarButton.title = RoomDetailsPurpose.Create.rawValue
        case .Edit:
            rightBarButton.title = RoomDetailsPurpose.Edit.rawValue
        case .View:
            rightBarButton.title = RoomDetailsPurpose.View.rawValue
        }
    }
    
    func getRestaurants() {
        cloudKitHelper.loadRestaurantRecords({ [weak self] restaurants in
            self?.restaurants.appendContentsOf(restaurants)
            self?.picker.reloadComponent(0)
        }, errorHandler: nil)
    }
    
    func enableUserInteraction(bool: Bool) {
        ownerTextField.userInteractionEnabled = false
        placeTextField.userInteractionEnabled = bool
        dateTextField.userInteractionEnabled = bool
        hourTextField.userInteractionEnabled = bool
        limitSlider.userInteractionEnabled = bool
        privateSwitch.userInteractionEnabled = bool
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
    
    func createRoom() {
        if room == nil {
            room?.owner?.recordID = userRecordID
            room?.restaurant?.recordID = CKRecordID(recordName: "temp") // this line will be replaced by actual restaurant record id
            room?.maxCount = Int(limitSlider.value)
            room?.accessType = AccessType(rawValue: privateSwitch.on ? 1 : 2)
            if let day = dateTextField.text, hour = hourTextField.text {
                room?.date = formatter.dateFromString(day, hour: hour)
            }
        }
    }
    
    @IBAction func barButtonPressed(sender: UIBarButtonItem) {
        guard let purpose = viewPurpose else {
            return
        }
        
        switch purpose {
        case .Create:
            createRoom()
        case .Edit:
            break
        case .View:
            break
        }
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
