//
//  CatalogManager.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/18/22.
//

import SwiftUI

final class CatalogManager: ObservableObject {
    @Published var location: SavedLocation
    @Published var date: Date
    @Published var reportSettings: ReportSettings
    
    init(location: SavedLocation, date: Date, reportSettings: ReportSettings) {
        self.location = location
        self.date = date
        self.reportSettings = reportSettings
    }
    
    // Sort Control Variables
    @Published var currentSort: SortMethod = .ra
    @Published var sortDecending: Bool = true
    @Published var targets: [DeepSkyTarget] = Array(DeepSkyTargetList.whitelistedTargets.values).sorted(by: {$0.ra > $1.ra})
    
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
    @Published var minMerScore: Double = 0
    
    // Modal Control Variables
    @Published var isAllFilterModal: Bool = false
    @Published var isTypeModal: Bool = false
    @Published var isConstellationModal: Bool = false
    @Published var isCatalogModal: Bool = false
    @Published var isMagModal: Bool = false
    @Published var isSizeModal: Bool = false
    @Published var isMerScoreModal: Bool = false
    @Published var isVisScoreModal: Bool = false
    
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
        case .meridian:
            minMerScore = 0
        case .visibility:
            minVisScore = 0
        }
    }
    
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
        
    func refreshList(sunData: SunData) {
        // reset list
        targets = DeepSkyTargetList.whitelistedTargets.values.sorted(by: {$0.ra > $1.ra})
        
        //filter by current active filters
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
        if isActive(criteria: minVisScore) {
            targets.filterByVisibility(minVisScore, location: location, date: date, sunData: sunData, limitingAlt: reportSettings.limitingAltitude)
        }
        if isActive(criteria: minMerScore) {
            targets.filterByMeridian(minMerScore, location: location, date: date, sunData: sunData)
        }
        
        // sort the list
        switch currentSort {
        case .visibility:
            targets.sortByVisibility(location: location, date: date, sunData: sunData, limitingAlt: reportSettings.limitingAltitude)
        case .meridian:
            targets.sortByMeridian(location: location, date: date, sunData: sunData)
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
