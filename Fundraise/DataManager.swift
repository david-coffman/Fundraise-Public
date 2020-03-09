//
//  DataManager.swift
//  Fundraise
//
//  Created by David Coffman on 12/29/19.
//  Copyright © 2019 David Coffman. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DataManager {
    static let inboxPath: URL = {
        let inboxPath = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Inbox")
        if let _ = try? FileManager().contentsOfDirectory(at: inboxPath, includingPropertiesForKeys: nil, options: []) {}
        else {
            try! FileManager().createDirectory(at: inboxPath, withIntermediateDirectories: true, attributes: nil)
        }
        return inboxPath
    }()
    static let defaultDataPath = Bundle.main.url(forResource: "default", withExtension: "csv")!
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yy"
        return dateFormatter
    }()
    
    let managedContext: NSManagedObjectContext!
    var useDefaultData: Bool
    var delegate: MainTableViewController!
    
    init(useDefaultData: Bool) {
        self.useDefaultData = useDefaultData
        managedContext = (UIApplication.shared.delegate! as! AppDelegate).persistentContainer.newBackgroundContext()
    }
    
    func performDataLoad(url: URL?) {
        var reader: StreamReader!
        if let url = url {
            reader = StreamReader(url: url)!
            reader.skipLine()
        }
        else {
            reader = StreamReader(url: DataManager.defaultDataPath)!
            reader.skipLine()
        }
        var i = 0
        while let line = reader.nextLine() {
            autoreleasepool{
                resolveDonationFromLine(line: line)
                i += 1
                if i % 10000 == 0 {saveManagedContext()}
            }
        }
        saveManagedContext()
    }
    
    func resolveDonationFromLine(line: String) {
        let lineSplit = line.components(separatedBy: ",")
        var donor: Donor!
        guard !lineSplit[0].contains("Aggregated") && lineSplit[8].contains("Individual") else {return}
        if let existingDonor = checkExistingDonorFromLine(lineSplit: lineSplit) {
            donor = existingDonor
        }
        else {
            donor = (NSManagedObject(entity: Donor.entity(), insertInto: managedContext) as! Donor)
            donor.name = lineSplit[0]
            donor.streetAddress = lineSplit[1]
            donor.city = lineSplit[3]
            donor.state = lineSplit[4]
            donor.zip = Int16(lineSplit[5])!
            donor.profession = lineSplit[6]
            donor.employer = lineSplit[7]
            donor.hasDonated = false
            donor.hasContacted = false
        }
        addDonationFromSplitIfAbsent(donorID: donor.objectID, lineSplit: lineSplit)
    }
    
    func checkExistingDonorFromLine(lineSplit: [String]) -> Donor? {
        let fetchRequest = NSFetchRequest<Donor>(entityName: "Donor")
        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "name == %@", lineSplit[0]))
        predicates.append(NSPredicate(format: "streetAddress == %@", lineSplit[1]))
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let results = try! managedContext.fetch(fetchRequest)
        return results.first
    }
    
    func addDonationFromSplitIfAbsent(donorID: NSManagedObjectID, lineSplit: [String]) {
        let donor = managedContext.object(with: donorID) as! Donor
        var predicates = [NSPredicate]()
        predicates.append(NSPredicate(format: "amount == \(Float(lineSplit[19])!)"))
        predicates.append(NSPredicate(format: "recipient == %@", lineSplit[9]))
        predicates.append(NSPredicate(format: "date == %@", DataManager.dateFormatter.date(from: lineSplit[17])! as NSDate))
        if let _ = donor.donations!.filtered(using: NSCompoundPredicate(andPredicateWithSubpredicates: predicates)).first {
            return
        }
        else {
            let donation = Donation(entity: Donation.entity(), insertInto: managedContext)
            donation.amount = Float(lineSplit[19])!
            donation.date = DataManager.dateFormatter.date(from: lineSplit[17])!
            donation.recipient = lineSplit[9]
            donor.addToDonations(donation)
        }
    }
    
    func dataError() {
        delegate.throwDataErrorWarning(code: 2)
    }
    
    func saveManagedContext() {
        do {
            try managedContext.save()
            delegate.performReload()
        }
        catch {
            dataError()
        }
    }
    
    func getResultsController(filter: NSPredicate?, sort: NSSortDescriptor?, query: String?) -> NSFetchedResultsController<Donor> {
        var predicate: NSPredicate!
        if let filter = filter {
            predicate = filter
        }
        else {
            predicate = NSPredicate(value: true)
        }
        if let query = query {
            var predicates = [NSPredicate]()
            for k in query.split(separator: " ") {
                predicates.append(NSPredicate(format: "name CONTAINS %@", String(k).uppercased()) )
            }
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates+[predicate])
        }
        
        let fetchRequest = NSFetchRequest<Donor>(entityName: "Donor")
        fetchRequest.predicate = predicate
        if let sortDescriptor = sort {
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        else {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        }
        let controller = NSFetchedResultsController<Donor>(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        return controller
    }
}
