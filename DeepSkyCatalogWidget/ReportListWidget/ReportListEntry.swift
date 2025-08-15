//
//  ReportListEntry.swift
//  DeepSkyCatalogWidgetExtension
//
//  Created by Ryan Sponzilli on 1/3/23.
//

import Foundation
import WidgetKit
import DeepSkyCore

struct ReportListEntry: TimelineEntry {
    let date: Date
    let targets: [DeepSkyTarget]
    let rows: Int
    let error: Error?
    
    init(date: Date, targets: [DeepSkyTarget], rows: Int, error: Error? = nil) {
        self.date = date
        self.targets = targets
        self.rows = rows
        self.error = error
    }
    
    static func placeholder(error: Error? = nil) -> ReportListEntry {
        let exampleTargets = [
            DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == "4DF4D75D-75C2-410A-8B71-58E0DCEB7BBA"})!,
            DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == "2891B251-C444-4A8F-AF41-F0B27F8AEA9A"})!,
            DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == "D1352706-8B37-499D-979B-6635C97F6902"})!,
            DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == "48211243-452B-4AF3-B60B-F392F68069B4"})!,
            DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == "163BACE8-7268-409B-90EA-27F10CCD4C10"})!
        ]
                
        return ReportListEntry(date: Date(), targets: exampleTargets, rows: 3, error: error)
    }
}
