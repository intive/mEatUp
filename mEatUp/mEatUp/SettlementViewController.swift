//
//  SettlementViewController.swift
//  mEatUp
//
//  Created by Maciej Plewko on 13.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class SettlementViewController: UIViewController {
    
}

extension SettlementViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ParticipantDebtCell", forIndexPath: indexPath)
        return cell
    }
    
    //function added only to conform UITableViewDataSource protocol
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
}