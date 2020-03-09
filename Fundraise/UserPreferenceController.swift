//
//  UserPreferenceController.swift
//  Fundraise
//
//  Created by David Coffman on 12/29/19.
//  Copyright © 2019 David Coffman. All rights reserved.
//

import Foundation
import CoreData

class UserPreferenceController: Codable {
    static let preferenceURL = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("pref").appendingPathExtension("json")
    static let shared: UserPreferenceController = {
        if let data = try? Data(contentsOf: UserPreferenceController.preferenceURL) {
            if let ret = try? JSONDecoder().decode(UserPreferenceController.self, from: data) {return ret}
        }
        return UserPreferenceController()
    }()
    
    // Sorting Preferences
    var sortKeyName: String
    var sortAscending: Bool
    
    // Filtering Preferences
    var donorDisplayMode: Bool?
    var contactDisplayMode: Bool?
    
    var filter: NSPredicate {
        var predicates = [NSPredicate]()
        if let donorDisplayMode = donorDisplayMode {
            if donorDisplayMode {predicates.append(NSPredicate(format: "hasDonated == YES"))}
            else {predicates.append(NSPredicate(format: "hasDonated == NO"))}
        }
        if let contactDisplayMode = contactDisplayMode {
            if contactDisplayMode {predicates.append(NSPredicate(format: "hasContacted == YES"))}
            else {predicates.append(NSPredicate(format: "hasContacted == NO"))}
        }
        if predicates.count > 0 {
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        return NSPredicate(value: true)
    }
    var sort: NSSortDescriptor {
        return NSSortDescriptor(key: sortKeyName, ascending: true)
    }
    
    init() {
        sortKeyName = "name"
        sortAscending = true
        save()
    }
    
    func save() {
        try! JSONEncoder().encode(self).write(to: UserPreferenceController.preferenceURL)
    }

}
