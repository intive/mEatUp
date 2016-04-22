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
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var hourTextField: UITextField!
    @IBOutlet weak var limitSlider: UISlider!
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var privateSwitch: UISwitch!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var topLabel: UILabel!
    
    var activeField: UITextField?
    var room: Room?
    var chosenRestaurant: Restaurant?
    let datePicker = DatePickerWithDoneButton()
    let formatter = NSDateFormatter()
    
    let cloudKitHelper = CloudKitHelper()
    
    var viewPurpose: RoomDetailsPurpose?
    var userRecordID: CKRecordID?
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        limitLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func placeTextFieldEditing(sender: UITextField) {
        performSegueWithIdentifier("ShowRestaurantListViewController", sender: nil)
        self.view.endEditing(true)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navigationCtrl = segue.destinationViewController as? UINavigationController, let destination = navigationCtrl.topViewController as? RestaurantListViewController {
            destination.saveRestaurant = { [weak self] restaurant in
                self?.placeTextField.text = restaurant.name
                self?.chosenRestaurant = restaurant
            }
        }
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
        
        determineViewPurpose()
        
        if let purpose = viewPurpose {
            setupViewForPurpose(purpose)
        }
        
        limitLabel.text = "\(room?.maxCount ?? Int(limitSlider.minimumValue))"
        datePicker.locale = NSLocale(localeIdentifier: "PL")
        registerForKeyboardNotifications()
        self.navigationController?.navigationBar.translucent = false;
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func determineViewPurpose() {
        if room == nil {
            viewPurpose = RoomDetailsPurpose.Create
        } else if room?.owner?.recordID == userRecordID {
            viewPurpose = RoomDetailsPurpose.Edit
        } else {
            viewPurpose = RoomDetailsPurpose.View
        }
    }
    
    func setupViewForPurpose(purpose: RoomDetailsPurpose) {
        switch purpose {
        case .Create:
            rightBarButton.title = RoomDetailsPurpose.Create.rawValue
            enableUserInteraction(true)
        case .Edit:
            if let room = room {
                configureWithRoom(room)
            }
            rightBarButton.title = RoomDetailsPurpose.Edit.rawValue
            enableUserInteraction(true)
        case .View:
            topLabel.text = "Owner"
            topTextField.placeholder = "Owner"
            if let room = room {
                configureWithRoom(room)
            }
            navigationItem.rightBarButtonItems?.removeAll()
            enableUserInteraction(false)
        }
    }
    
    func enableUserInteraction(bool: Bool) {
        topTextField.userInteractionEnabled = bool
        placeTextField.userInteractionEnabled = bool
        dateTextField.userInteractionEnabled = bool
        hourTextField.userInteractionEnabled = bool
        limitSlider.userInteractionEnabled = bool
        privateSwitch.userInteractionEnabled = bool
    }
    
    func configureWithRoom(room: Room) {
        title = "\(room.title ?? "Room")"
        
        if let name = room.owner?.name, let surname = room.owner?.surname, let date = room.date, let limit = room.maxCount, let access = room.accessType {
            if let purpose = viewPurpose {
                switch purpose {
                case .View:
                    topTextField.text = "\(name) \(surname)"
                case .Edit:
                    topTextField.text = room.title
                case .Create:
                    break
                }
            }
            placeTextField.text = room.restaurant?.name
            hourTextField.text = formatter.stringFromDate(date, withFormat: "H:mm")
            dateTextField.text = formatter.stringFromDate(date, withFormat: "dd.MM.yyyy")
            limitSlider.value = Float(limit)
            privateSwitch.on = access == AccessType.Private ? true : false
        }
    }
    
    func createRoom() {
        room = Room()
        room?.owner?.recordID = userRecordID
        room?.maxCount = Int(limitSlider.value)
        room?.accessType = AccessType(rawValue: privateSwitch.on ? AccessType.Private.rawValue : AccessType.Public.rawValue)
        room?.title = topTextField.text
        if let day = dateTextField.text, hour = hourTextField.text {
            room?.date = formatter.dateFromString(day, hour: hour)
        }
        if let restaurant = chosenRestaurant {
            room?.restaurant = restaurant
        }
        
        if let room = room {
            cloudKitHelper.saveRoomRecord(room, completionHandler: {
                if let userRecordID = self.userRecordID, let roomRecordID = room.recordID {
                    let userInRoom = UserInRoom(userRecordID: userRecordID, roomRecordID: roomRecordID, confirmationStatus: ConfirmationStatus.Accepted)
                    self.cloudKitHelper.saveUserInRoomRecord(userInRoom, completionHandler: {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }, errorHandler: nil)
                }
            }, errorHandler: nil)
        }
    }
    
    func updateRoom(room: Room) {
        room.title = topTextField.text
        room.restaurant?.name = placeTextField.text
        if let day = dateTextField.text, hour = hourTextField.text {
            room.date = formatter.dateFromString(day, hour: hour)
        }
        room.maxCount = Int(limitSlider.value)
        room.accessType = AccessType(rawValue: privateSwitch.on ? AccessType.Private.rawValue : AccessType.Public.rawValue)
        if let restaurant = chosenRestaurant {
            room.restaurant = restaurant
        }
        
        cloudKitHelper.editRoomRecord(room, completionHandler: {
            self.dismissViewControllerAnimated(true, completion: nil)
            }, errorHandler: nil)
    }
    
    @IBAction func barButtonPressed(sender: UIBarButtonItem) {
        guard let purpose = viewPurpose else {
            return
        }
        
        switch purpose {
        case .Create:
            createRoom()
        case .Edit:
            if let room = room {
                updateRoom(room)
            }
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
        if textField == hourTextField || textField == dateTextField || textField == placeTextField {
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
