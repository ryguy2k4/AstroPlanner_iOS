//
//  DailyReport.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/27/22.
//

import Foundation
import SwiftUI

final class DailyReport: ObservableObject {
    let location: SavedLocation
    let date: Date
    let reportSettings: ReportSettings
    let targetSettings: TargetSettings
    let data: (sun: SunData, moon: MoonData)
    let presetList: FetchedResults<ImagingPreset>
    
    let topFive: [DeepSkyTarget]
    let topTenNebulae: [DeepSkyTarget]
    let topTenGalaxies: [DeepSkyTarget]
    let topTenStarClusters: [DeepSkyTarget]
    
    init(location: SavedLocation, date: Date, reportSettings: ReportSettings, targetSettings: TargetSettings, presetList: FetchedResults<ImagingPreset>, data: (sun: SunData, moon: MoonData)) {
        self.location = location
        self.date = date
        self.reportSettings = reportSettings
        self.targetSettings = targetSettings
        self.data = data
        self.presetList = presetList
                
        self.topFive = createReportList(top: 5)
        self.topTenNebulae = createReportList(for: TargetType.nebulae, top: 10)
        self.topTenGalaxies = createReportList(for: TargetType.galaxies, top: 10)
        self.topTenStarClusters = createReportList(for: TargetType.starClusters, top: 10)
        
        func createReportList(for type: [TargetType] = [], top num: Int) -> [DeepSkyTarget] {
            // start with all targets
            var targets = getAvailableTargets()
            
            // filter by desired types
            if !type.isEmpty {
                targets.filterByType(type)
            }
            
            // filter by selected imaging preset
            targets = targets.filter { target in
                let ratio = target.arcLength / presetList.first!.fovLength
                return ratio > reportSettings.minFOVCoverage && ratio <= 0.9
            }
            
            targets.sortByVisibility(location: location, date: date, sunData: data.sun, limitingAlt: targetSettings.limitingAltitude)
            targets.removeLast(targets.count > num ? targets.count-num : 0)
            return targets
        }
        
        /**
         Filters the list for broadband or narrowband based on the status of the moon
         */
        func getAvailableTargets() -> [DeepSkyTarget] {
            var targets = Array(DeepSkyTargetList.whitelistedTargets)
            targets.filterByVisibility(reportSettings.minVisibility, location: location, date: date, sunData: data.sun, limitingAlt: targetSettings.limitingAltitude)
            
            // if moon is a problem, filter for narrowband
            if data.moon.illuminated > reportSettings.maxAllowedMoon {
                targets.filterByType(TargetType.narrowband)
            }
            // if moon is not a problem, but broadband preferred, filter for broadband only
            else if reportSettings.preferBroadband {
                targets.filterByType(TargetType.broadband)
            }
            return targets
        }
    }
}
