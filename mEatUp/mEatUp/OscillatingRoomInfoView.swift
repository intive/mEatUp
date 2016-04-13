//
//  OscillatingRoomInfo.swift
//  mEatUp
//
//  Created by Krzysztof Przybysz on 12/04/16.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class OscillatingRoomInfoView: UIView {
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    var timer: NSTimer?
    var room: Room?
    var isSwapped = true
    lazy var formatter = NSDateFormatter()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let view = NSBundle.mainBundle().loadNibNamed("OscillatingRoomInfoView", owner: self, options: nil)[0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func startWithRoom(room: Room) {
        self.room = room
        swapInfo()
        formatter.dateFormat = "H:mm"
        
        timer = NSTimer.scheduledTimerWithTimeInterval(6.0,
            target: self,
            selector: #selector(fadeOut),
            userInfo: nil,
            repeats: true)
    }
    
    @objc private func fadeOut() {
        UIView.animateWithDuration(1.0,
            delay: 0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: {
                self.alpha = 0.0
            },
            completion: fadeIn)
    }
    
    private func fadeIn(isFinished: Bool) {
        if isFinished {
            UIView.animateWithDuration(1.0,
                delay: 0, options: UIViewAnimationOptions.AllowUserInteraction,
                animations: {
                    self.alpha = 1.0
                    self.swapInfo()
                },
                completion: nil)
        }
    }
    
    private func swapInfo() {
        if isSwapped {
            if let ownerName = room?.owner?.name, let ownerSurname = room?.owner?.surname, let title = room?.title {
                topLabel.text = title
                bottomLabel.text = "\(ownerName) \(ownerSurname)"
            }
        } else {
            if  let date = room?.date, let restaurantName = room?.restaurant?.name {
                topLabel.text = restaurantName
                bottomLabel.text = "\(formatter.stringFromDate(date))"
            }
        }
        isSwapped = !isSwapped
    }
    
}
