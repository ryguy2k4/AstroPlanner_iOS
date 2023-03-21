//
//  CatalogManager.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/18/22.
//

import SwiftUI

final class CatalogManager: ObservableObject {
    
    // Sort Control Variables
    @Published var currentSort: SortMethod = .ra
    @Published var sortDecending: Bool = true
    @Published var targets: [DeepSkyTarget] = DeepSkyTargetList.whitelistedTargets.sorted(by: {$0.ra > $1.ra})
    
    // Filter Control Variables
    @Published var searchText = ""
    @Published var catalogSelection: [TargetCatalog] = []
    @Published var constellationSelection: [Constellation] = []
    @Published var typeSelection: [TargetType] = []
    @Published var brightestMag: Double = 0
    @Published var dimmestMag: Double = .nan
    @Published var minSize: Double = 0
    @Published var maxSize: Double = .nan
    @Published var minVisScore: Double = 0
    @Published var minSeasonScore: Double = 0
    
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
            brightestMag = 0
            dimmestMag = .nan
        case .size:
            minSize = 0
            maxSize = .nan
        case .seasonScore:
            minSeasonScore = 0
        case .visibility:
            minVisScore = 0
        }
    }
    
    /**
     Determines if a filter control variable contains does not contain its default value
     */
    func isActive<T>(criteria: T) -> Bool {
        switch criteria {
        case let array as Array<Any>:
            return !array.isEmpty
        case let string as String:
            return !string.isEmpty
        case let double as Double:
            return !double.isZero
        case let range as (min: Double, max: Double):
            return !range.min.isZero || !range.max.isNaN
        default:
            return false
        }
    }
    
    /**
     Re-filters and re-sorts the list
     */
    func refreshList(date: Date, viewingInterval: DateInterval, location: Location, targetSettings: TargetSettings, sunData: SunData?) {
        // reset list
        targets = DeepSkyTargetList.whitelistedTargets.sorted(by: {$0.ra > $1.ra})
        if targetSettings.hideNeverRises {
            for target in targets {
                if case .never = target.getNextInterval(location: location, date: date).interval {
                    targets.removeAll(where: {$0 == target})
                }
            }
        }
        
        // filter by current active filters
        if isActive(criteria: searchText) {
            targets.filterBySearch(searchText)
        }
        if isActive(criteria: catalogSelection) {
            targets.filterByCatalog(catalogSelection)
        }
        if isActive(criteria: constellationSelection) {
            targets.filterByConstellation(constellationSelection)
        }
        if isActive(criteria: typeSelection) {
            targets.filterByType(typeSelection)
        }
        if isActive(criteria: (min: brightestMag, max: dimmestMag)) {
            targets.filterByMag(brightest: brightestMag, dimmest: dimmestMag)
        }
        if isActive(criteria: (min: minSize, max: maxSize)) {
            targets.filterBySize(min: minSize, max: maxSize)
        }
        if let sunData = sunData {
            if isActive(criteria: minVisScore) {
                targets.filterByVisibility(minVisScore, location: location, viewingInterval: viewingInterval, sunData: sunData, limitingAlt: targetSettings.limitingAltitude)
            }
            if isActive(criteria: minSeasonScore) {
                targets.filterBySeasonScore(minSeasonScore, location: location, date: date, sunData: sunData)
            }
        }
        
        // sort the list
        switch currentSort {
        case .visibility:
            if let sunData = sunData {
                targets.sortByVisibility(location: location, viewingInterval: viewingInterval, sunData: sunData, limitingAlt: targetSettings.limitingAltitude)
            }
        case .seasonScore:
            if let sunData = sunData {
                targets.sortByMeridian(location: location, date: date, sunData: sunData)
            }
        case .dec:
            targets.sortByDec()
        case .ra:
            targets.sortByRA()
        case .magnitude:
            targets.sortByMagnitude()
        case .size:
            targets.sortBySize()
        }
        
        if !sortDecending {
            targets.reverse()
        }
    }
}
