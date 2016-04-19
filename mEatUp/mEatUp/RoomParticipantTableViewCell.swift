//
//  RoomParticipantTableViewCell.swift
//  mEatUp
//
//  Created by Krzysztof Przybysz on 19/04/16.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class RoomParticipantTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    func configureWithRoom(user: User) {
        nameLabel.text = "\(user.name ?? "") \(user.surname ?? "")"
//        user.photo = "https://scontent.fwaw3-1.fna.fbcdn.net/hphotos-xaf1/v/t1.0-9/374213_283413375043181_689553604_n.jpg?oh=6dd2ac9a55150b4b663fcb398c63f575&oe=57AB61B6"
        if let photoURL = user.photo {
            if let checkedUrl = NSURL(string: photoURL) {
                self.imgView.contentMode = .ScaleAspectFit
                downloadImage(checkedUrl)
            }
        }
    }
    
    private func downloadImage(url: NSURL){
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                self.imgView.image = UIImage(data: data)
            }
        }
    }
    
    private func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }

}
