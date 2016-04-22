//
//  RestaurantTableViewCell.swift
//  mEatUp
//
//  Created by Krzysztof Przybysz on 21/04/16.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    func configureWithRestaurant(restaurant: Restaurant) {
        nameLabel.text = restaurant.name
    }

}
