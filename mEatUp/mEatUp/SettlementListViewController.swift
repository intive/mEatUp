//
//  SettlementListViewController.swift
//  mEatUp
//
//  Created by Maciej Plewko on 12.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import CoreData

class SettlementListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let ReuseIdentifierWebsiteCell = "FinishedRoomCell"
    let coreDataController = CoreDataController()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let websitesFetchRequest = NSFetchRequest(entityName: FinishedRoom.entityName())
        let primarySortDescriptor = NSSortDescriptor( key: "date", ascending: false)
        websitesFetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let frc = NSFetchedResultsController(
            fetchRequest: websitesFetchRequest,
            managedObjectContext: self.coreDataController.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // only for testing core data //
        coreDataController.addTestFinishedRooms()
        // ************************** //
        fetch()
    }
    
    func fetch() {
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Fetch error occurred")
        }
    }
}

extension SettlementListViewController: UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifierWebsiteCell, forIndexPath: indexPath) //as? FinishedRoomCell
        let finishedRoom = fetchedResultsController.objectAtIndexPath(indexPath) as? FinishedRoom
        if let cell = cell as? FinishedRoomCell, room = finishedRoom {
            cell.configureWithRoom(room)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections, let objects = sections[section].objects {
            return objects.count
        }
        
        return 0
    }
}