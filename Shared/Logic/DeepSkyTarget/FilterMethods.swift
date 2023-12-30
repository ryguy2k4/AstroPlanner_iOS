//
//  FilterMethods.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/12/23.
//

import Foundation

enum FilterMethod: Identifiable {
    var id: Self { self }
    case search
    case catalog
    case constellation
    case type
    case magnitude
    case size
    case visibility
    case seasonScore    
    
    var info: (name: String, icon: String) {
            switch self {
            case .search:
                return ("Search", "magnifyingglass")
            case .catalog:
                return ("Catalog", "list.star")
            case .constellation:
                return ("Constellation", "star")
            case .type:
                return ("Type", "atom")
            case .magnitude:
                return ("Magnitude", "sun.min.fill")
            case .size:
                return ("Size", "arrow.up.left.and.arrow.down.right")
            case .visibility:
                return ("Visibility", "eye.fill")
            case .seasonScore:
                return ("Season", "calendar.circle")
            }
        }
}

extension Array where Element == DeepSkyTarget {
    
    /// FILTER BY SEARCH
    func filteredBySearch(_ searchText: String) -> Self {
        return self.filter { target in
            target.designation.contains(where: {$0.longDescription.localizedStandardContains(searchText)}) ||
            target.subDesignations.contains(where: {$0.longDescription.localizedStandardContains(searchText)}) ||
            target.designation.contains(where: {$0.shortDescription.localizedStandardContains(searchText)}) ||
            target.subDesignations.contains(where: {$0.shortDescription.localizedStandardContains(searchText)}) ||
            target.name?.contains(where: {$0.localizedCaseInsensitiveContains(searchText)}) ?? false ||
            target.defaultName.localizedCaseInsensitiveContains(searchText)
        }
    }
        
    mutating func filterBySearch(_ searchText: String) {
        self = self.filteredBySearch(searchText)
    }
    
    /// FILTER BY CATALOG
    func filteredByCatalog(_ catalogSelection: Set<TargetCatalog>) -> Self {
        return self.filter() {
            for catalog in catalogSelection {
                for item in $0.designation {
                    if item.catalog == catalog { return true }
                }
            }
            return false
        }
    }
    
    mutating func filterByCatalog(_ catalogSelection: Set<TargetCatalog>) {
        self = self.filteredByCatalog(catalogSelection)
    }
    
    /// FILTER BY CONSTELLATION
    func filteredByConstellation(_ constellationSelection: Set<Constellation>) -> Self {
        return self.filter() {
            for constellation in constellationSelection {
                if $0.constellation == constellation { return true }
            }
            return false
        }
    }
    
    mutating func filterByConstellation(_ constellationSelection: Set<Constellation>) {
        self = self.filteredByConstellation(constellationSelection)
    }
    
    /// FILTER BY TYPE
    func filteredByType(_ typeSelection: Set<TargetType>) -> Self {
        return self.filter() {
            for type in typeSelection {
                if $0.type == type { return true }
            }
            return false
        }
    }
    
    mutating func filterByType(_ typeSelection: Set<TargetType>) {
        self = self.filteredByType(typeSelection)
    }
    
    /// FILTER BY MAGNITUDE
    func filteredByMagnitude(brightest: Double, dimmest: Double) -> Self {
        return self.filter() {
            if dimmest.isNaN {
                return $0.apparentMag ?? .greatestFiniteMagnitude >= brightest
            }
            return $0.apparentMag ?? .greatestFiniteMagnitude >= brightest && $0.apparentMag ?? .greatestFiniteMagnitude <= dimmest
        }
    }
    
    mutating func filterByMag(brightest min: Double, dimmest max: Double) {
        self = self.filteredByMagnitude(brightest: min, dimmest: max)
    }
    
    /// FILTER BY SIZE
    func filteredBySize(min: Double, max: Double) -> Self {
        return self.filter() {
            if max.isNaN {
                return $0.arcLength >= min
            }
            return $0.arcLength >= min && $0.arcLength <= max
        }
    }
    
    mutating func filterBySize(min: Double, max: Double) {
        self = self.filteredBySize(min: min, max: max)
    }
    
    /// FILTER BY VISIBILITY SCORE
    func filteredByVisibility(min: Double, location: Location, viewingInterval: DateInterval, sunData: SunData, limitingAlt: Double) -> Self {
        return self.filter() {
            return $0.getVisibilityScore(at: location, viewingInterval: viewingInterval, sunData: sunData, limitingAlt: limitingAlt) >= min
        }
    }
    
    mutating func filterByVisibility(_ min: Double, location: Location, viewingInterval: DateInterval, sunData: SunData, limitingAlt: Double) {
        self = self.filteredByVisibility(min: min, location: location, viewingInterval: viewingInterval, sunData: sunData, limitingAlt: limitingAlt)
    }
    
    /// FILTER BY MERIDIAN SCORE
    func filteredBySeasonScore(min: Double, location: Location, date: Date, sunData: SunData) -> Self {
        return self.filter() {
            return $0.getSeasonScore(at: location, on: date, sunData: sunData) >= min
        }
    }
    
    mutating func filterBySeasonScore(_ min: Double, location: Location, date: Date, sunData: SunData) {
        self = self.filteredBySeasonScore(min: min, location: location, date: date, sunData: sunData)
    }
}
