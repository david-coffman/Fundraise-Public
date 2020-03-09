//
//  ImportTableViewController.swift
//  Fundraise
//
//  Created by David Coffman on 1/10/20.
//  Copyright © 2020 David Coffman. All rights reserved.
//

import UIKit

class ImportTableViewController: UITableViewController {
    
    var dataManager: DataManager!
    var availableFiles: [URL] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        availableFiles = try! FileManager().contentsOfDirectory(at: DataManager.inboxPath, includingPropertiesForKeys: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableFiles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basic", for: indexPath)
        cell.textLabel!.text = availableFiles[indexPath.row].lastPathComponent
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dataManager.performDataLoad(url: availableFiles[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Files will appear here after you copy them to the app."
    }
}
