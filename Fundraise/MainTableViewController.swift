//
//  MainTableViewController.swift
//  Fundraise
//
//  Created by David Coffman on 12/29/19.
//  Copyright © 2019 David Coffman. All rights reserved.
//

import UIKit
import CoreData

class MainTableViewController: UITableViewController, UISearchBarDelegate {
    
    var dataManager = DataManager(useDefaultData: true)
    var preferenceController = UserPreferenceController.shared
    var fetchedResultsControllers = [NSFetchedResultsController<Donor>]()
    var selectedIndexPath: IndexPath!
    var searchText: String?

    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        dataManager.delegate = self
        dataManager.performDataLoad(url: nil)
        performReload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        performReload()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsControllers.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(fetchedResultsControllers.count == 0) {return 0}
        return fetchedResultsControllers[section].fetchedObjects!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "donorCell", for: indexPath) as! DonorTableViewCell
        let donor = fetchedResultsControllers[indexPath.section].fetchedObjects![indexPath.row]
        cell.configure(name: donor.name!, hasBeenContacted: donor.hasContacted, hasDonated: donor.hasDonated)
        return cell
    }
    
    func throwDataErrorWarning(code: Int?) {
        var errmsg: String!
        switch code {
        case 1:
            errmsg = "It seems we've encountered an error while importing your data. Check that your data is formatted correctly, then try again."
        case 2:
            errmsg = "It seems we've encountered an error while loading your data from memory."
        default:
            errmsg = "We've encountered an unexpected error."
        }
        let alertController = UIAlertController(title: "Uh-oh!", message: errmsg, preferredStyle: .alert)
        present(alertController, animated: true, completion: nil)
    }
    
    func performReload() {
        fetchedResultsControllers = []
        fetchedResultsControllers.append(dataManager.getResultsController(filter: preferenceController.filter, sort: preferenceController.sort, query: searchText))
        for k in fetchedResultsControllers {
            do {
                try k.performFetch()
            }
            catch {
                throwDataErrorWarning(code: 2)
            }
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndexPath = indexPath
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let destination = segue.destination as? DonorDetailTableViewController {
                destination.dataManager = self.dataManager
                destination.donorID = fetchedResultsControllers[selectedIndexPath.section].fetchedObjects![selectedIndexPath.row].objectID
            }
        }
        if segue.identifier == "import" {
            if let target = segue.destination as? ImportTableViewController {
                target.dataManager = self.dataManager
            }
        }
        if segue.identifier == "filter" {
            
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchText = searchBar.text
        performReload()
    }
    
    @IBAction func filterData(_ sender: Any) {
        performSegue(withIdentifier: "filter", sender: self)
    }
    
    @IBAction func importData(_ sender: Any) {
        performSegue(withIdentifier: "import", sender: self)
    }
}
