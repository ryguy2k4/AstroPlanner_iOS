//
//  CatalogManager.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/18/22.
//

import Foundation
import SwiftUI
import DeepSkyCore

final class CatalogManager: ObservableObject {
    
    @Published var targets: [DeepSkyTarget] = []
    
    // Sort Control Variables
    @Published var currentSort: SortMethod = .ra
    @Published var sortDecending: Bool = true
    
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
     Reset the associated filter control variable
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
     Re-filter and re-sort the list
     */
    func refreshList(date: Date, viewingInterval: DateInterval?, location: Location, targetSettings: TargetSettings, sunData: SunData?) {
        // get a fresh list
        targets = DeepSkyTargetList.whitelistedTargets(hiddenTargets: targetSettings.hiddenTargets!).sorted(by: {$0.ra > $1.ra})
        
        // check for hide never rises
        if targetSettings.hideNeverRises {
            for target in targets {
                if case .never = target.getNextInterval(location: location, date: date).interval {
                    targets.removeAll(where: {$0 == target})
                }
            }
        }
        
        // apply active filters
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
    
    func refreshSortOrder() {
        targets.reverse()
    }
}
