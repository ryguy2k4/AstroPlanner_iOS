//
//  CatalogViewModel.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/18/22.
//

import SwiftUI

final class CatalogViewModel: ObservableObject {
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
    @Published var targets: [DeepSkyTarget] = DeepSkyTargetList.allTargets.sorted(by: {$0.ra > $1.ra})
    
    // Filter Control Variables
    @Published var searchText = ""
    @Published var catalogSelection: [DSOCatalog] = []
    @Published var constellationSelection: [Constellation] = []
    @Published var typeSelection: [DSOType] = []
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
        
    func refreshList(sunData: SunData) {
        // reset list
        targets = DeepSkyTargetList.allTargets.sorted(by: {$0.ra > $1.ra})
        
        //filter by current active filters
        if !searchText.isEmpty {
            targets.filterBySearch(searchText)
        }
        if !catalogSelection.isEmpty {
            targets.filterByCatalog(catalogSelection)
        }
        if !constellationSelection.isEmpty {
            targets.filterByConstellation(constellationSelection)
        }
        if !typeSelection.isEmpty {
            targets.filterByType(typeSelection)
        }
        if !brightestMag.isZero || !dimmestMag.isNaN {
            targets.filterByMag(brightest: brightestMag, dimmest: dimmestMag)
        }
        if !minSize.isZero || !maxSize.isNaN {
            targets.filterBySize(min: minSize, max: maxSize)
        }
        if !minVisScore.isZero {
            targets.filterByVisibility(minVisScore, location: location, date: date, sunData: sunData, limitingAlt: reportSettings.limitingAltitude)
        }
        if !minMerScore.isZero {
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
