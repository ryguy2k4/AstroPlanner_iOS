//
//  CatalogManager.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/18/22.
//

import Foundation
import SwiftUI

final class CatalogManager: ObservableObject {
    
    // Sort Control Variables
    @Published var currentSort: SortMethod = .ra
    @Published var sortDecending: Bool = true
    @Published var targets: [DeepSkyTarget] = []
    
    // Filter Control Variables
    // filters are enabled if they are not nil
    @Published var searchText = ""
    @Published var catalogSelection: Set<TargetCatalog> = []
    @Published var constellationSelection: Set<Constellation> = []
    @Published var typeSelection: Set<TargetType> = []
    @Published var brightestMag: Double? = nil
    @Published var dimmestMag: Double? = nil
    @Published var minSize: Double? = nil
    @Published var maxSize: Double? = nil
    @Published var minVisScore: Double? = nil
    @Published var minSeasonScore: Double? = nil
    
    /**
     Sets the filter control variable associated with the specified filter to its default value(s)
     */
    func clearFilter(for method: FilterMethod) {
        switch method {
        case .search:
            searchText = ""
        case .catalog:
            catalogSelection = []
        case .constellation:
            constellationSelection = []
        case .type:
            typeSelection = []
        case .magnitude:
            brightestMag = nil
            dimmestMag = nil
        case .size:
            minSize = nil
            maxSize = nil
        case .seasonScore:
            minSeasonScore = nil
        case .visibility:
            minVisScore = nil
        }
    }
    
    /**
     Re-filters and re-sorts the list
     */
    func refreshList(date: Date, viewingInterval: DateInterval?, location: Location, targetSettings: TargetSettings, sunData: SunData?) {
        // reset list
        targets = DeepSkyTargetList.whitelistedTargets(hiddenTargets: targetSettings.hiddenTargets!).sorted(by: {$0.ra > $1.ra})
        if targetSettings.hideNeverRises {
            for target in targets {
                if case .never = target.getNextInterval(location: location, date: date).interval {
                    targets.removeAll(where: {$0 == target})
                }
            }
        }
        
        // filter by current active filters
        if !searchText.isEmpty {
            targets = targets.filteredBySearch(searchText)
        }
        if !catalogSelection.isEmpty {
            targets = targets.filteredByCatalog(catalogSelection)
        }
        if !constellationSelection.isEmpty {
            targets = targets.filteredByConstellation(constellationSelection)
        }
        if !typeSelection.isEmpty {
            targets = targets.filteredByType(typeSelection)
        }
        
        if brightestMag != nil || dimmestMag != nil {
            targets = targets.filteredByMagnitude(brightest: brightestMag, dimmest: dimmestMag)
        }
        
        if minSize != nil || maxSize != nil {
            targets = targets.filteredBySize(min: minSize, max: maxSize)
        }
        
        if let sunData = sunData, let viewingInterval = viewingInterval {
            if let minVisScore = minVisScore {
                targets = targets.filteredByVisibility(min: minVisScore, location: location, viewingInterval: viewingInterval, limitingAlt: targetSettings.limitingAltitude)
            }
            if let minSeasonScore = minSeasonScore {
                targets = targets.filteredBySeasonScore(min: minSeasonScore, location: location, date: date, sunData: sunData)
            }
        }
        
        // sort the list
        switch currentSort {
        case .visibility:
            if let viewingInterval = viewingInterval {
                targets = targets.sortedByVisibility(location: location, viewingInterval: viewingInterval, limitingAlt: targetSettings.limitingAltitude)
            }
        case .seasonScore:
            if let sunData = sunData {
                targets = targets.sortedByMeridian(location: location, date: date, sunData: sunData)
            }
        case .dec:
            targets = targets.sortedByDec()
        case .ra:
            targets = targets.sortedByRA()
        case .magnitude:
            targets = targets.sortedByMagnitude()
        case .size:
            targets = targets.sortedBySize()
        }
        
        if !sortDecending {
            targets.reverse()
        }
    }
}
