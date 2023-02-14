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
        let hiddenTargets = try! PersistenceManager.shared.container.viewContext.fetch(NSFetchRequest<TargetSettings>(entityName: "TargetSettings")).first!.hiddenTargets!.allObjects as! [HiddenTarget]
        var whitelist = allTargets
        for item in hiddenTargets {
            whitelist.removeAll(where: {$0.id == item.id})
        }
        return whitelist
    }
    
    static var objects: [DeepSkyTarget] {
        let decoder = JSONDecoder()
        let json = try! Data(contentsOf: Bundle.main.url(forResource: "Catalog", withExtension: "json")!)
        let array = try! decoder.decode([DeepSkyTarget].self, from: json)
        
        var messier: [DeepSkyTarget] = []
        var caldwell: [DeepSkyTarget] = []
        var other: [DeepSkyTarget] = []
        
        for item in array {
            if item.designation.contains(where: {$0.catalog == .messier}) {
                messier.append(item)
            } else if item.designation.contains(where: {$0.catalog == .caldwell}) {
                caldwell.append(item)
            } else {
                other.append(item)
            }
        }
        messier.sort(by: {$0.designation.first(where: {$0.catalog == .messier})!.number < $1.designation.first(where: {$0.catalog == .messier})!.number})
        caldwell.sort(by: {$0.designation.first(where: {$0.catalog == .caldwell})!.number < $1.designation.first(where: {$0.catalog == .caldwell})!.number})
        return messier + caldwell + other
    }
    
    static func exportObjects(list: [DeepSkyTarget]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(list)
            if #available(macOS 13.0, *) {
                let path = URL(filePath: "/Users/ryansponzilli/Documents/Xcode/DeepSkyCatalog/Shared/DeepSkyTarget/Catalog.json")
                try data.write(to: path)
                print("data exported")
            } else {
                // Fallback on earlier versions
            }

        } catch {
            print("error exporting")
        }
    }
}
