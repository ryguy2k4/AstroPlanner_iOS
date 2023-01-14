//
//  DeepSkyTargetList.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/7/22.
//

import Foundation
import Swift

struct DeepSkyTargetList {
    static var allTargets: [DeepSkyTarget] = {
        let decoder = JSONDecoder()
        let json = try! Data(contentsOf: Bundle.main.url(forResource: "Catalog", withExtension: "json")!)
        return try! decoder.decode([DeepSkyTarget].self, from: json)
    }()
}
