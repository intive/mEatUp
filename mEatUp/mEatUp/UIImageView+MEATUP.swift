//
//  UIImageView+MEATUP.swift
//  mEatUp
//
//  Created by Maciej Plewko on 19.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

extension UIImageView {
    private func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func setFacebookImageFromUrl(url: NSURL) {
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                self.image = UIImage(data: data)
            }
        }
    }

}