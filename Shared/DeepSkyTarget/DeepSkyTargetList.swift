//
//  DeepSkyTargetList.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/7/22.
//

import Foundation
import Swift
import CoreData

struct DeepSkyTargetList {
    static var allTargets: [DeepSkyObject] {
        let decoder = JSONDecoder()
        let json = try! Data(contentsOf: Bundle.main.url(forResource: "Catalog", withExtension: "json")!)
        return try! decoder.decode([DeepSkyObject].self, from: json)
    }
    
    static var whitelistedTargets: [DeepSkyObject] {
        let hiddenTargets = try! PersistenceManager.shared.container.viewContext.fetch(NSFetchRequest<TargetSettings>(entityName: "TargetSettings")).first!.hiddenTargets!.allObjects as! [HiddenTarget]
        var whitelist = allTargets
        for item in hiddenTargets {
            whitelist.removeAll(where: {$0.id == item.id})
        }
        return whitelist
    }
}
