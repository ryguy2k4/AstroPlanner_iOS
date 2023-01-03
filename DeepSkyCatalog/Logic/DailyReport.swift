//
//  DailyReportViewModel.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/27/22.
//

import Foundation

final class DailyReport: ObservableObject {
    let location: SavedLocation
    let date: Date
    let settings: ReportSettings
    let data: (sun: SunData, moon: MoonData)
    let preset: ImagingPreset
    
    let topThree: [DeepSkyTarget]
    let topFiveNebulae: [DeepSkyTarget]
    let topFiveGalaxies: [DeepSkyTarget]
    let topFiveStarClusters: [DeepSkyTarget]
    
    init(location: SavedLocation, date: Date, settings: ReportSettings, preset: ImagingPreset, data: (sun: SunData, moon: MoonData)) {
        self.location = location
        self.date = date
        self.settings = settings
        self.data = data
        self.preset = preset
                
        self.topThree = createReportList(top: 3)
        self.topFiveNebulae = createReportList(for: DSOType.nebulae, top: 5)
        self.topFiveGalaxies = createReportList(for: DSOType.galaxies, top: 5)
        self.topFiveStarClusters = createReportList(for: DSOType.starClusters, top: 5)
        
        func createReportList(for type: [DSOType] = [], top num: Int) -> [DeepSkyTarget] {
            // start with all targets
            var targets = getAvailableTargets()
            
            // filter by desired types
            if !type.isEmpty {
                targets.filter(byTypeSelection: type)
            }
            
            // filter by selected imaging preset
            targets.filter(byMinSize: preset.fovLength / 4, byMaxSize: preset.fovLength / 2)
            
            // filter by desired magnitude
            //targets.filter(byBrightestMag: settings.brightestMag, byDimmestMag: settings.dimmestMag)
            
            targets.sort(by: .visibility, sortDescending: true, location: location, date: date, sunData: data.sun)
            targets.removeLast(targets.count > num ? targets.count-num : 0)
            return targets
        }
        
        /**
         Filters the list for broadband or narrowband based on the status of the moon
         */
        func getAvailableTargets() -> [DeepSkyTarget] {
            var targets = DeepSkyTargetList.allTargets
            targets.filter(byMinVisScore: 0.8, at: location, on: date, sunData: data.sun)
            
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
