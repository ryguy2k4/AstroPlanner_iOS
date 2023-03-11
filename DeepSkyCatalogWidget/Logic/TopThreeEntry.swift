//
//  TopThreeEntry.swift
//  DeepSkyCatalogWidgetExtension
//
//  Created by Ryan Sponzilli on 1/3/23.
//

import Foundation
import WidgetKit

struct TopThreeEntry: TimelineEntry {
    let date: Date
    let topThree: [DeepSkyTarget]
    
    static var placeholder: TopThreeEntry {
        let exampleTargets = [
            DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == "4DF4D75D-75C2-410A-8B71-58E0DCEB7BBA"})!,
            DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == "2891B251-C444-4A8F-AF41-F0B27F8AEA9A"})!,
            DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == "D1352706-8B37-499D-979B-6635C97F6902"})!
        ]
                
        return TopThreeEntry(date: Date(), topThree: exampleTargets)
    }
}
