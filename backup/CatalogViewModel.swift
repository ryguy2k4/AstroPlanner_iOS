//
//  CatalogViewModel.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/18/22.
//

import SwiftUI

final class CatalogViewModel: ObservableObject {
    @Published var currentSort: SortMethod = .ra
    @Published var sortDecending: Bool = true
    @Published var targets: [DeepSkyTarget] = DeepSkyTargetList.allTargets.sorted(by: {$0.ra > $1.ra})
    
    @Published var searchText = ""
    @Published var catalogSelection: [DSOCatalog] = []
    @Published var constellationSelection: [Constellation] = []
    @Published var typeSelection: [DSOType] = []
    
    func sortTargets(by method: SortMethod, with appConfig: AppConfig) {
        var sortedTargets = targets
        if sortDecending {
            switch method {
            case .visibility:
                sortedTargets.sort(by: {$0.getVisibilityScore(with: appConfig) > $1.getVisibilityScore(with: appConfig)})
            case .meridian:
                sortedTargets.sort(by: {$0.getMeridianScore(with: appConfig) > $1.getMeridianScore(with: appConfig)})
            case .dec:
                sortedTargets.sort(by: {$0.dec > $1.dec})
            case .ra:
                sortedTargets.sort(by: {$0.ra > $1.ra})
                
            }
        } else {
            switch method {
            case .visibility:
                sortedTargets.sort(by: {$0.getVisibilityScore(with: appConfig) < $1.getVisibilityScore(with: appConfig)})
            case .meridian:
                sortedTargets.sort(by: {$0.getMeridianScore(with: appConfig) < $1.getMeridianScore(with: appConfig)})
            case .dec:
                sortedTargets.sort(by: {$0.dec < $1.dec})
            case .ra:
                sortedTargets.sort(by: {$0.ra < $1.ra})
            }
        }
        currentSort = method
        targets = sortedTargets
    }
    
    private func filterBySearch() {
        if (searchText == "") {
            clearFilter(for: .search)
        } else {
            targets = targets.filter({$0.description.localizedCaseInsensitiveContains(searchText)})
        }
    }
    private func filterByCatalog() {
        targets = targets.filter() {
            var containsThis = false
            for catalog in catalogSelection {
                for item in $0.designation where !containsThis {
                    containsThis = (item.catalog == catalog)
                }
            }
            return containsThis
        }
    }
    private func filterByConstellation() {
        targets = targets.filter() {
            var containsThis = false
            for constellation in constellationSelection where !containsThis {
                containsThis = ($0.constellation == constellation)
            }
            return containsThis
        }
    }
    private func filterByType() {
        targets = targets.filter() {
            var containsThis = false
            for type in typeSelection {
                for item in $0.type where !containsThis {
                    containsThis = (item == type)
                }
            }
            return containsThis
        }
    }
    
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
        }
        refreshList()
    }
    
    func refreshList() {
        // reset list
        targets = DeepSkyTargetList.allTargets.sorted(by: {$0.ra > $1.ra})
        
        //filter by current active filters
        if !searchText.isEmpty {
            filterBySearch()
        }
        if !catalogSelection.isEmpty {
            filterByCatalog()
        }
        if !constellationSelection.isEmpty {
            filterByConstellation()
        }
        if !typeSelection.isEmpty {
            filterByType()
        }
    }
}
