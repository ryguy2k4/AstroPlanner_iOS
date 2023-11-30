//
//  DeepSkyTargetList.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/7/22.
//

import Foundation
import CoreData

struct DeepSkyTargetList {
    static var allTargets: [DeepSkyTarget] = {
        let decoder = JSONDecoder()
        let json = try! Data(contentsOf: Bundle.main.url(forResource: "Catalog", withExtension: "json")!)
        return try! decoder.decode([DeepSkyTarget].self, from: json)
    }()
    
    static var whitelistedTargets: [DeepSkyTarget] = {
        let hiddenTargets = try! PersistenceManager.shared.container.viewContext.fetch(NSFetchRequest<TargetSettings>(entityName: "TargetSettings")).first!.hiddenTargets!.allObjects as! [HiddenTarget]
        var whitelist = allTargets
        for item in hiddenTargets {
            whitelist.removeAll(where: {$0.id == item.id})
        }
        return whitelist
    }()
    
    static func exportObjects(list: [DeepSkyTarget]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(list)
            if #available(macOS 13.0, *) {
                let path = URL(filePath: "/Users/ryansponzilli/Developer/DeepSkyCatalog/Shared/DeepSkyTarget/Catalog.json")
                try data.write(to: path)
               print("data exported")
            } else {
                // Fallback on earlier versions
            }

        } catch {
           print("error exporting: \(error)")
        }
    }
}
