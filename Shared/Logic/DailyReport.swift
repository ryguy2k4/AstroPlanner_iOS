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
    let preset: ImagingPreset?
    
    let topFive: [DeepSkyTarget]
    let topTenNebulae: [DeepSkyTarget]
    let topTenGalaxies: [DeepSkyTarget]
    let topTenStarClusters: [DeepSkyTarget]
    
    init(location: Location, date: Date, viewingInterval: DateInterval, reportSettings: ReportSettings, targetSettings: TargetSettings, preset: ImagingPreset?, sunData: SunData) {
        self.location = location
        self.date = date
        self.viewingInterval = viewingInterval
        self.reportSettings = reportSettings
        self.targetSettings = targetSettings
        self.sunData = sunData
        self.preset = preset
        
        let targets = generateSuitableTargets()
        self.topFive = createReportList(with: targets, top: 5)
        self.topTenNebulae = createReportList(with: targets, for: TargetType.nebulae, top: 10)
        self.topTenGalaxies = createReportList(with: targets, for: TargetType.galaxies, top: 10)
        self.topTenStarClusters = createReportList(with: targets, for: TargetType.starClusters, top: 10)
        
        func generateSuitableTargets() -> [DeepSkyTarget] {
            // start with all whitelisted targets
            var targets = Array(DeepSkyTargetList.whitelistedTargets)
            
            // Remove all targets with a meridian score less than 50%
            // ** Need to account for edge cases where meridian score doesn't effect visibility at extreme declinations
            targets.filterBySeasonScore(0.5, location: location, date: date, sunData: sunData)
            
            // Remove all targets with a visibility score less than the user specified minimum
            targets.filterByVisibility(reportSettings.minVisibility, location: location, viewingInterval: viewingInterval, sunData: sunData, limitingAlt: targetSettings.limitingAltitude)
            
            // Moon Phase Based Filtering
            if reportSettings.filterForMoonPhase {
                
                // if bright moon is visible filter for narrowband targets
                let moonIllumination = Moon.getMoonIllumination(date: date, timezone: location.timezone)
                if moonIllumination > reportSettings.maxAllowedMoon {
                    targets.filterByType(TargetType.narrowband)
                }
                // if moon is not a problem, but broadband preferred --> move broadband targets to the top of the list
                else if reportSettings.preferBroadband {
                    var narrowband: [DeepSkyTarget] = []
                    for target in targets where TargetType.narrowband.contains(target.type) {
                        narrowband.append(target)
                        targets.removeAll(where: {$0 == target})
                    }
                    targets.append(contentsOf: narrowband)
                    targets.filterByType(TargetType.broadband)
                }
                
                // else (new moon) --> do not filter anything, all is fine
            }
            
            // filter for selected imaging preset, if one is selected
            if let preset = preset {
                targets = targets.filter { target in
                    let ratio = target.arcLength / preset.fovLength
                    return ratio > reportSettings.minFOVCoverage && ratio <= 0.9
                }
            }
            
            return targets
        }
        
        func createReportList(with targets: [DeepSkyTarget], for type: Set<TargetType> = [], top num: Int) -> [DeepSkyTarget] {
            
            var targets = targets
            
            // filter for desired types passed to function
            if !type.isEmpty {
                targets.filterByType(type)
            }
            
            // Time Save Optimization
            // if the list can be filtered down, this avoids needlessly sorting a few lines down at the time hog
            let smallTargetsArray = targets.filteredByVisibility(min: 0.95, location: location, viewingInterval: viewingInterval, sunData: sunData, limitingAlt: targetSettings.limitingAltitude)
            if smallTargetsArray.count >= 10 {
                targets = smallTargetsArray
            }
            
            // Sort the list by visibility
            // TIME HOG ALERT
            targets.sortByVisibility(location: location,viewingInterval: viewingInterval, sunData: sunData, limitingAlt: targetSettings.limitingAltitude)
            
            // Shorten the list to desired number passed to function
            targets.removeLast(targets.count > num ? targets.count-num : 0)
            
            return targets
        }
    }
}
