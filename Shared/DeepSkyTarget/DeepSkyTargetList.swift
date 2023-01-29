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
    static var allTargets: [DeepSkyTarget] {
        let decoder = JSONDecoder()
        let json = try! Data(contentsOf: Bundle.main.url(forResource: "Catalog", withExtension: "json")!)
        return try! decoder.decode([DeepSkyTarget].self, from: json)
    }
    
    static var whitelistedTargets: [DeepSkyTarget] {
        let hiddenTargets = try! PersistenceManager.shared.container.viewContext.fetch(NSFetchRequest<ReportSettings>(entityName: "ReportSettings")).first!.hiddenTargets!.allObjects as! [HiddenTarget]
        var whitelist = allTargets
        for item in hiddenTargets {
            whitelist.removeAll(where: {$0.id == item.id})
        }
        return whitelist
    }
}
