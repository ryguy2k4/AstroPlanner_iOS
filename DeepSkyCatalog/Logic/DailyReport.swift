//
//  DailyReportViewModel.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/27/22.
//

import Foundation
import SwiftUI

final class DailyReport: ObservableObject {
    let location: SavedLocation
    let date: Date
    let settings: ReportSettings
    let data: (sun: SunData, moon: MoonData)
    let presetList: FetchedResults<ImagingPreset>
    
    let topFive: [DeepSkyTarget]
    let topTenNebulae: [DeepSkyTarget]
    let topTenGalaxies: [DeepSkyTarget]
    let topTenStarClusters: [DeepSkyTarget]
    
    init(location: SavedLocation, date: Date, settings: ReportSettings, presetList: FetchedResults<ImagingPreset>, data: (sun: SunData, moon: MoonData)) {
        self.location = location
        self.date = date
        self.settings = settings
        self.data = data
        self.presetList = presetList
                
        self.topFive = createReportList(top: 5)
        self.topTenNebulae = createReportList(for: DSOType.nebulae, top: 10)
        self.topTenGalaxies = createReportList(for: DSOType.galaxies, top: 10)
        self.topTenStarClusters = createReportList(for: DSOType.starClusters, top: 10)
        
        func createReportList(for type: [DSOType] = [], top num: Int) -> [DeepSkyTarget] {
            // start with all targets
            var targets = getAvailableTargets()
            
            // filter by desired types
            if !type.isEmpty {
                targets.filter(byTypeSelection: type)
            }
            
            // filter by selected imaging preset
            targets = targets.filter { target in
                let ratio = target.arcLength / presetList.first!.fovLength
                return ratio > settings.minFOVCoverage && ratio <= 0.9
            }
            //targets.filter(byMinSize: preset.fovLength / 4, byMaxSize: preset.fovLength / 2)
            
            // filter by desired magnitude
            //targets.filter(byBrightestMag: settings.brightestMag, byDimmestMag: settings.dimmestMag)
            
            targets.sort(by: .visibility, sortDescending: true, location: location, date: date, sunData: data.sun, limitingAlt: settings.limitingAltitude)
            targets.removeLast(targets.count > num ? targets.count-num : 0)
            return targets
        }
        
        /**
         Filters the list for broadband or narrowband based on the status of the moon
         */
        func getAvailableTargets() -> [DeepSkyTarget] {
            var targets = DeepSkyTargetList.allTargets
            targets.filter(byMinVisScore: settings.minVisibility, at: location, on: date, sunData: data.sun, limitingAlt: settings.limitingAltitude)
            
            // if moon is a problem, filter for narrowband
            if data.moon.illuminated > settings.maxAllowedMoon {
                targets.filter(byTypeSelection: DSOType.narrowband)
            }
            // if moon is not a problem, but broadband preferred, filter for broadband only
            else if settings.preferBroadband {
                targets.filter(byTypeSelection: DSOType.broadband)
            }
            return targets
        }
    }
}
