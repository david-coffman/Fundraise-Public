//
//  DonorDetailTableViewController.swift
//  Fundraise
//
//  Created by David Coffman on 12/31/19.
//  Copyright © 2019 David Coffman. All rights reserved.
//

import UIKit
import CoreData

class DonorDetailTableViewController: UITableViewController {
    
    var dataManager: DataManager!
    var donorID: NSManagedObjectID!
    var donor: Donor!
    var donations: [Donation]!

    override func viewDidLoad() {
        super.viewDidLoad()
        donor = (dataManager.managedContext.object(with: donorID) as! Donor)
        donations =  (donor.donations!.sortedArray(using: [NSSortDescriptor(key: "date", ascending: false)]) as! [Donation])
        title = donor.name?.capitalized
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "This Campaign"
        case 1:
            return "Biographical"
        case 2:
            return "Donation History"
        default:
            return "Unimplemented"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 3
        case 2:
            return (donor.donations?.count ?? 0) + 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        switch indexPath.section {
        // Section 0: Donor Donation/Contact Information
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "basicWithImage", for: indexPath)
            switch indexPath.row {
            // Donation Information
            case 0:
                cell.textLabel?.text = donor.hasDonated ? "Has Donated" : "Has Not Donated"
                cell.imageView?.image = donor.hasDonated ? UIImage(systemName: "checkmark.seal.fill") : UIImage(systemName: "xmark.seal.fill")
                cell.imageView?.tintColor = donor.hasDonated ? .systemGreen : .systemRed
            // Contact Information
            case 1:
                cell.textLabel?.text = donor.hasContacted ? "Has Been Contacted" : "Has Not Been Contacted"
                cell.imageView?.image = donor.hasContacted ? UIImage(systemName: "person.crop.circle.badge.checkmark") : UIImage(systemName: "person.crop.circle.badge.xmark")
                cell.imageView?.tintColor = donor.hasContacted ? .systemGreen : .systemRed
            default:
                fatalError("Bad IndexPath.")
            }
        // Section 1: Biographical
        case 1:
            switch indexPath.row {
            // Address
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: "subtitle", for: indexPath)
                cell.textLabel!.text = "Address"
                cell.detailTextLabel!.text = "\(donor.streetAddress ?? "")"+"\n"+"\(donor.city ?? ""), \(donor.state ?? "") \(donor.zip)"
            // Profession
            case 1:
                cell = tableView.dequeueReusableCell(withIdentifier: "rightDetail", for: indexPath)
                cell.textLabel!.text = "Profession"
                cell.detailTextLabel!.text = (donor.profession ?? "") != "" ? donor.profession : "Unavailable"
            // Employer
            case 2:
                cell = tableView.dequeueReusableCell(withIdentifier: "rightDetail", for: indexPath)
                cell.textLabel!.text = "Employer"
                cell.detailTextLabel!.text = (donor.employer ?? "") != "" ? donor.employer : "Unavailable"
            default:
                fatalError("Bad IndexPath.")
            }
            
        // Section 2: Donation History
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "rightDetail", for: indexPath)
            if indexPath.row == 0 {
                cell.textLabel!.text = "Total Donations"
                cell.detailTextLabel!.text = "\(donor.donations!.count)"
            }
            else {
                cell.textLabel!.text = "\(donations[indexPath.row - 1].recipient!) (\(DataManager.dateFormatter.string(from: donations[indexPath.row - 1].date!)))"
                cell.detailTextLabel!.text = "\(donations[indexPath.row - 1].amount)"
            }
        default:
            fatalError("Bad IndexPath.")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath {
        case [0,0]:
            donor.hasDonated.toggle()
            tableView.reloadData()
            try! dataManager.managedContext.save()
        case [0,1]:
            donor.hasContacted.toggle()
            tableView.reloadData()
            try! dataManager.managedContext.save()
        default:
            break
        }
    }

    @IBAction func searchMobileManager(_ sender: Any) {
        let searchURL = URL(string: "mobilemanager://search")!.appendingPathComponent(donor.name!).appendingPathComponent(donor.streetAddress!)
        if UIApplication.shared.canOpenURL(URL(string: "mobilemanager://test")!) {
            UIApplication.shared.open(searchURL, options: [:])
        }
        else {
            let alertController = UIAlertController(title: "Not Installed", message: "You must have the MMDispatch app installed to search the voter database.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
}
