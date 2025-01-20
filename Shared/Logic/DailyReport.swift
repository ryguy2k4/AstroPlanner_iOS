//
//  DailyReport.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/27/22.
//

import Foundation

final class DailyReport {
    let topFive: [DeepSkyTarget]
    let topTenNebulae: [DeepSkyTarget]
    let topTenGalaxies: [DeepSkyTarget]
    let topTenStarClusters: [DeepSkyTarget]
    
    init(location: Location, date: Date, viewingInterval: DateInterval, reportSettings: ReportSettings, targetSettings: TargetSettings, preset: ImagingPreset?, sunData: SunData) {
        
        let targets = generateSuitableTargets()
        self.topFive = createReportList(with: targets, top: 5)
        self.topTenNebulae = createReportList(with: targets, for: TargetType.nebulae, top: 10)
        self.topTenGalaxies = createReportList(with: targets, for: TargetType.galaxies, top: 10)
        self.topTenStarClusters = createReportList(with: targets, for: TargetType.starClusters, top: 10)
        
        func generateSuitableTargets() -> [DeepSkyTarget] {
            // start with all whitelisted targets
            var targets = DeepSkyTargetList.whitelistedTargets(hiddenTargets: targetSettings.hiddenTargets ?? [])
            
            // Never Visible Filter
            targets = targets.filter {
                $0.dec  > (location.latitude - 90.0)
            }
            
            // Remove all targets with a meridian score less than 50%
            // ** Need to account for edge cases where meridian score doesn't effect visibility at extreme declinations
            targets = targets.filteredBySeasonScore(min: 0.5, location: location, date: date, sunData: sunData)
            
            // Remove all targets with a visibility score less than the user specified minimum
            targets = targets.filteredByVisibility(min: reportSettings.minVisibility, location: location, viewingInterval: viewingInterval, limitingAlt: targetSettings.limitingAltitude)
            
            // Moon Phase Based Filtering
            if reportSettings.filterForMoonPhase {
                
                // if bright moon is visible filter for narrowband targets
                let moonIllumination = Moon.getMoonIllumination(date: date)
                if moonIllumination > reportSettings.maxAllowedMoon {
                    targets = targets.filteredByType(TargetType.narrowband)
                }
                // if moon is not a problem, but broadband preferred --> move broadband targets to the top of the list
                else if reportSettings.preferBroadband {
                    var narrowband: [DeepSkyTarget] = []
                    for target in targets where TargetType.narrowband.contains(target.type) {
                        narrowband.append(target)
                        targets.removeAll(where: {$0 == target})
                    }
                    targets.append(contentsOf: narrowband)
                    targets = targets.filteredByType(TargetType.broadband)
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
                targets = targets.filteredByType(type)
            }
            
            // Time Save Optimization
            // if the list can be filtered down, this avoids needlessly sorting a few lines down at the time hog
            let smallTargetsArray = targets.filteredByVisibility(min: 0.95, location: location, viewingInterval: viewingInterval, limitingAlt: targetSettings.limitingAltitude)
            if smallTargetsArray.count >= 10 {
                targets = smallTargetsArray
            }
            
            // Sort the list by visibility
            // TIME HOG ALERT
            targets = targets.sortedByVisibility(location: location,viewingInterval: viewingInterval, limitingAlt: targetSettings.limitingAltitude)
            targets = targets.sortedByMeridian(location: location, date: date, sunData: sunData)
            
            // Shorten the list to desired number passed to function
            targets.removeLast(targets.count > num ? targets.count-num : 0)
            
            return targets
        }
    }
}
