//
//  FilterMethods.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/12/23.
//

import Foundation

enum FilterMethod {
    case search
    case catalog
    case constellation
    case type
    case magnitude
    case size
    case visibility
    case meridian    
    
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
            case .meridian:
                return ("Meridian", "arrow.right.and.line.vertical.and.arrow.left")
            }
        }
}

protocol Filter: RawRepresentable<String>, Identifiable, Hashable, CaseIterable where AllCases == Array<Self> {
    static var name: String { get }
}

extension Array where Element == DeepSkyTarget {
    
    /// FILTER BY SEARCH
    func filteredBySearch(_ searchText: String) -> Self {
        return self.filter({$0.description.localizedCaseInsensitiveContains(searchText)})
    }
        
    mutating func filterBySearch(_ searchText: String) {
        self = self.filteredBySearch(searchText)
    }
    
    /// FILTER BY CATALOG
    func filteredByCatalog(_ catalogSelection: [TargetCatalog]) -> Self {
        return self.filter() {
            for catalog in catalogSelection {
                for item in $0.designation {
                    if item.catalog == catalog { return true }
                }
            }
            return false
        }
    }
    
    mutating func filterByCatalog(_ catalogSelection: [TargetCatalog]) {
        self = self.filteredByCatalog(catalogSelection)
    }
    
    /// FILTER BY CONSTELLATION
    func filteredByConstellation(_ constellationSelection: [Constellation]) -> Self {
        return self.filter() {
            for constellation in constellationSelection {
                if $0.constellation == constellation { return true }
            }
            return false
        }
    }
    
    mutating func filterByConstellation(_ constellationSelection: [Constellation]) {
        self = self.filteredByConstellation(constellationSelection)
    }
    
    /// FILTER BY TYPE
    func filteredByType(_ typeSelection: [TargetType]) -> Self {
        return self.filter() {
            for type in typeSelection {
                for item in $0.type {
                    if item == type { return true }
                }
            }
            return false
        }
    }
    
    mutating func filterByType(_ typeSelection: [TargetType]) {
        self = self.filteredByType(typeSelection)
    }
    
    /// FILTER BY MAGNITUDE
    func filteredByMagnitude(brightest: Double, dimmest: Double) -> Self {
        return self.filter() {
            if dimmest.isNaN {
                return $0.apparentMag >= brightest
            }
            return $0.apparentMag >= brightest && $0.apparentMag <= dimmest
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
    func filteredByVisibility(min: Double, location: SavedLocation, date: Date, sunData: SunData, limitingAlt: Double) -> Self {
        return self.filter() {
            return $0.getVisibilityScore(at: location, on: date, sunData: sunData, limitingAlt: limitingAlt) >= min
        }
    }
    
    mutating func filterByVisibility(_ min: Double, location: SavedLocation, date: Date, sunData: SunData, limitingAlt: Double) {
        self = self.filteredByVisibility(min: min, location: location, date: date, sunData: sunData, limitingAlt: limitingAlt)
    }
    
    /// FILTER BY MERIDIAN SCORE
    func filteredByMeridian(min: Double, location: SavedLocation, date: Date, sunData: SunData) -> Self {
        return self.filter() {
            return $0.getMeridianScore(at: location, on: date, sunData: sunData) >= min
        }
    }
    
    mutating func filterByMeridian(_ min: Double, location: SavedLocation, date: Date, sunData: SunData) {
        self = self.filteredByMeridian(min: min, location: location, date: date, sunData: sunData)
    }
}
