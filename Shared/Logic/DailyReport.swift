//
//  DailyReport.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/27/22.
//

import Foundation
import SwiftUI

final class DailyReport: ObservableObject {
    let location: Location
    let date: Date
    let viewingInterval: DateInterval
    let reportSettings: ReportSettings
    let targetSettings: TargetSettings
    let sunData: SunData
    let presetList: [ImagingPreset]
    
    let topFive: [DeepSkyTarget]
    let topTenNebulae: [DeepSkyTarget]
    let topTenGalaxies: [DeepSkyTarget]
    let topTenStarClusters: [DeepSkyTarget]
    
    init(location: Location, date: Date, viewingInterval: DateInterval, reportSettings: ReportSettings, targetSettings: TargetSettings, presetList: [ImagingPreset], sunData: SunData) {
        self.location = location
        self.date = date
        self.viewingInterval = viewingInterval
        self.reportSettings = reportSettings
        self.targetSettings = targetSettings
        self.sunData = sunData
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
            targets.filterBySeasonScore(0.5, location: location, date: date, sunData: sunData)
            
            // Remove all targets with a visibility score less than the user specified minimum
            targets.filterByVisibility(reportSettings.minVisibility, location: location, viewingInterval: viewingInterval, sunData: sunData, limitingAlt: targetSettings.limitingAltitude)
            
            // if bright moon is visible filter for narrowband targets
            let moonIllumination = MoonData.getMoonIllumination(date: date)
            if moonIllumination > reportSettings.maxAllowedMoon {
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
            targets.sortByVisibility(location: location,viewingInterval: viewingInterval, sunData: sunData, limitingAlt: targetSettings.limitingAltitude)
            
            // Shorten the list to desired number passed to function
            targets.removeLast(targets.count > num ? targets.count-num : 0)
            
            return targets
        }
    }
}
