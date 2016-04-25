//
//  RestaurantListViewController.swift
//  mEatUp
//
//  Created by Krzysztof Przybysz on 21/04/16.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class RestaurantListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let cloudKitHelper = CloudKitHelper()
    let searchController = UISearchController(searchResultsController: nil)
    var restaurants = [Restaurant]()
    var filteredRestaurants = [Restaurant]()
    var saveRestaurant: ((Restaurant) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchController.loadViewIfNeeded()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationController?.navigationBar.translucent = false
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadRestaurants()
    }
    
    func loadRestaurants() {
        cloudKitHelper.loadRestaurantRecords({ [weak self] restaurants in
            self?.restaurants = restaurants
            self?.tableView.reloadData()
        }, errorHandler: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? RestaurantViewController  {
            destination.saveRestaurant = self.saveRestaurant
        }
    }
}

extension RestaurantListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.gotContentAndActive() ? filteredRestaurants.count : restaurants.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RestaurantCell", forIndexPath: indexPath)
        let restaurant = searchController.gotContentAndActive() ? filteredRestaurants[indexPath.row] : restaurants[indexPath.row]
        
        if let cell = cell as? RestaurantTableViewCell {
            cell.configureWithRestaurant(restaurant)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let restaurant = searchController.gotContentAndActive() ? filteredRestaurants[indexPath.row] : restaurants[indexPath.row]
        self.searchController.active = false
        dismissViewControllerAnimated(true) { [unowned self] in
            self.saveRestaurant?(restaurant)
        }
    }
}

extension RestaurantListViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            filterContentForSearchText(text)
        }
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredRestaurants = restaurants.filter { restaurant in
            guard let name = restaurant.name else { return false }
            return name.lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }
}
