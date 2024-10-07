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
            target.designation.contains(where: {$0.longDescription.localizedCaseInsensitiveContains(searchText)}) ||
            target.subDesignations.contains(where: {$0.longDescription.localizedCaseInsensitiveContains(searchText)}) ||
            target.designation.contains(where: {$0.shortDescription.localizedCaseInsensitiveContains(searchText)}) ||
            target.subDesignations.contains(where: {$0.shortDescription.localizedCaseInsensitiveContains(searchText)}) ||
            target.name?.contains(where: {$0.localizedCaseInsensitiveContains(searchText)}) ?? false ||
            target.defaultName.localizedCaseInsensitiveContains(searchText)
        }
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
    
    /// FILTER BY CONSTELLATION
    func filteredByConstellation(_ constellationSelection: Set<Constellation>) -> Self {
        return self.filter() {
            for constellation in constellationSelection {
                if $0.constellation == constellation { return true }
            }
            return false
        }
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
    
    /// FILTER BY MAGNITUDE
    func filteredByMagnitude(brightest: Double?, dimmest: Double?) -> Self {
        if brightest == nil && dimmest == nil { return self }
        return self.filter { ($0.apparentMag ?? .greatestFiniteMagnitude) >= (brightest ?? 0) && ($0.apparentMag ?? .greatestFiniteMagnitude) <= (dimmest ?? .greatestFiniteMagnitude) }
    }
    
    /// FILTER BY SIZE
    func filteredBySize(min: Double?, max: Double?) -> Self {
        if min == nil && max == nil { return self }
        return self.filter { $0.arcLength >= (min ?? 0) && $0.arcLength <= (max ?? .greatestFiniteMagnitude) }
    }
    
    /// FILTER BY VISIBILITY SCORE
    func filteredByVisibility(min: Double, location: Location, viewingInterval: DateInterval, limitingAlt: Double) -> Self {
        return self.filter() {
            return $0.getVisibilityScore(at: location, viewingInterval: viewingInterval, limitingAlt: limitingAlt) >= min
        }
    }
    
    /// FILTER BY MERIDIAN SCORE
    func filteredBySeasonScore(min: Double, location: Location, date: Date, sunData: SunData) -> Self {
        return self.filter() {
            return $0.getSeasonScore(at: location, on: date, sunData: sunData) >= min
        }
    }
}
