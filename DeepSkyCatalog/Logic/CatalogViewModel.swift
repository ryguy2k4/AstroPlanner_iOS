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
    
    init(location: SavedLocation, date: Date) {
        self.location = location
        self.date = date
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
            targets.filter(bySearchText: searchText)
        }
        if !catalogSelection.isEmpty {
            targets.filter(byCatalogSelection: catalogSelection)
        }
        if !constellationSelection.isEmpty {
            targets.filter(byConstellationSelection: constellationSelection)
        }
        if !typeSelection.isEmpty {
            targets.filter(byTypeSelection: typeSelection)
        }
        if !brightestMag.isZero || !dimmestMag.isNaN {
            targets.filter(byBrightestMag: brightestMag, byDimmestMag: dimmestMag)
        }
        if !minSize.isZero || !maxSize.isNaN {
            targets.filter(byMinSize: minSize, byMaxSize: maxSize)
        }
        if !minVisScore.isZero {
            targets.filter(byMinVisScore: minVisScore, at: location, on: date, sunData: sunData)
        }
        if !minMerScore.isZero {
            targets.filter(byMinMerScore: minMerScore, at: location, on: date, sunData: sunData)
        }
        targets.sort(by: currentSort, sortDescending: sortDecending, location: location, date: date, sunData: sunData)
    }
}
