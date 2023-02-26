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
    let viewingInterval: DateInterval
    let reportSettings: ReportSettings
    let targetSettings: TargetSettings
    let data: (sun: SunData, moon: MoonData)
    let presetList: FetchedResults<ImagingPreset>
    
    let topFive: [DeepSkyTarget]
    let topTenNebulae: [DeepSkyTarget]
    let topTenGalaxies: [DeepSkyTarget]
    let topTenStarClusters: [DeepSkyTarget]
    
    init(location: SavedLocation, date: Date, viewingInterval: DateInterval, reportSettings: ReportSettings, targetSettings: TargetSettings, presetList: FetchedResults<ImagingPreset>, data: (sun: SunData, moon: MoonData)) {
        self.location = location
        self.date = date
        self.viewingInterval = viewingInterval
        self.reportSettings = reportSettings
        self.targetSettings = targetSettings
        self.data = data
        self.presetList = presetList
                
        self.topFive = createReportList(top: 5)
        self.topTenNebulae = createReportList(for: TargetType.nebulae, top: 10)
        self.topTenGalaxies = createReportList(for: TargetType.galaxies, top: 10)
        self.topTenStarClusters = createReportList(for: TargetType.starClusters, top: 10)
        
        func createReportList(for type: [TargetType] = [], top num: Int) -> [DeepSkyTarget] {
            
            // start with all whitelisted targets
            var targets = Array(DeepSkyTargetList.whitelistedTargets)
            
            // Remove all targets with a meridian score less than 50%
            // ** Need to account for edge cases where meridian score doesn't effect visibility at extreme declinations
            targets.filterBySeasonScore(0.5, location: location, date: date, sunData: data.sun)
            
            // Remove all targets with a visibility score less than the user specified minimum
            targets.filterByVisibility(reportSettings.minVisibility, location: location, viewingInterval: viewingInterval, sunData: data.sun, limitingAlt: targetSettings.limitingAltitude)
            
            // if bright moon is visible for more than 10% of viewing interval, filter for narrowband targets
            if data.moon.illuminated > reportSettings.maxAllowedMoon && (data.moon.moonInterval.intersection(with: viewingInterval)?.duration ?? 0) > 0.1 * viewingInterval.duration {
                targets.filterByType(TargetType.narrowband)
            }
            // if moon is not a problem, but broadband preferred, filter for broadband only
            else if reportSettings.preferBroadband {
                targets.filterByType(TargetType.broadband)
            }
            
            // filter for desired types passed to function
            if !type.isEmpty {
                targets.filterByType(type)
            }
            
            // filter for selected imaging preset, if one is selected
            if let preset = presetList.first(where: {$0.isSelected == true}) {
                targets = targets.filter { target in
                    let ratio = target.arcLength / preset.fovLength
                    return ratio > reportSettings.minFOVCoverage && ratio <= 0.9
                }
            }
            
            // Sort the list by visibility
            targets.sortByVisibility(location: location,viewingInterval: viewingInterval, sunData: data.sun, limitingAlt: targetSettings.limitingAltitude)
            
            // Shorten the list to desired number passed to function
            targets.removeLast(targets.count > num ? targets.count-num : 0)
            
            return targets
        }
    }
}
