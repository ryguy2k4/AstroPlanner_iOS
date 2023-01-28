//
//  DeepSkyTargetList.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/7/22.
//

import Foundation
import Swift

struct DeepSkyTargetList {
    static var allTargets: [UUID: DeepSkyTarget] {
        let decoder = JSONDecoder()
        let json = try! Data(contentsOf: Bundle.main.url(forResource: "Catalog", withExtension: "json")!)
        let decoded = try! decoder.decode([String: DeepSkyTarget].self, from: json)
        
        var allTargets: [UUID: DeepSkyTarget] = [:]
        for (key, value) in decoded {
            allTargets[UUID(uuidString: key)!] = value
        }
        return allTargets
    }
    
    static var blacklist: [UUID] {
        return []
    }
    
    static var whitelistedTargets: [UUID: DeepSkyTarget] {
        var whitelist = allTargets
        for item in blacklist {
            whitelist[item] = nil
        }
        return whitelist
    }
}
