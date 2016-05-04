//
//  SettlementListViewController.swift
//  mEatUp
//
//  Created by Maciej Plewko on 12.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import CoreData
import FBSDKLoginKit

class SettlementListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let ReuseIdentifierWebsiteCell = "FinishedRoomCell"
    let finishedRoomListLoader = FinishedRoomListDataLoader()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: FinishedRoom.entityName())
        fetchRequest.predicate = NSPredicate(format: "isVisible == %@", true)
        let primarySortDescriptor = NSSortDescriptor( key: "date", ascending: false)
        fetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataController.sharedInstance.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(SettlementListViewController.handleManualRefresh(_:)), forControlEvents: .ValueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.addSubview(self.refreshControl)
        fetch()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    @IBAction func facebookLogout(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        if let loginView: LoginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController {
            FBSDKLoginManager().logOut()
            UserSettings().clearUserDetails()
            UIApplication.sharedApplication().keyWindow?.rootViewController = loginView
        }
    }
    
    func fetch() {
        refreshControl.beginRefreshing()
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Fetch error occurred")
            refreshControl.endRefreshing()
        }
        refreshControl.endRefreshing()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationVC = segue.destinationViewController as? SettlementViewController {
            var participantsToPass = [Participant]()
            
            if let indexPath = tableView.indexPathForSelectedRow, finishedRoom = fetchedResultsController.objectAtIndexPath(indexPath) as? FinishedRoom {
                destinationVC.finishedRoom = finishedRoom
                if let elements = finishedRoom.participants, participants =  elements.allObjects as? [Participant] {
                    participantsToPass = participants
                }
            }

            destinationVC.participants = participantsToPass
        }
    }
    
    func handleManualRefresh(refreshControl: UIRefreshControl) {
        fetch()
    }
}

extension SettlementListViewController: UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifierWebsiteCell, forIndexPath: indexPath)
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
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let objectToDelete = fetchedResultsController.objectAtIndexPath(indexPath) as? FinishedRoom
            if let objectToDelete = objectToDelete {
                objectToDelete.isVisible = false
                CoreDataController.sharedInstance.saveContext()
            }
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case NSFetchedResultsChangeType.Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
}
