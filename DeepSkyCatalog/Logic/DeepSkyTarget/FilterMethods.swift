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
        
    mutating func filter(bySearchText searchText: String) {
        self = self.filter({$0.description.localizedCaseInsensitiveContains(searchText)})
    }
    mutating func filter(byCatalogSelection catalogSelection: [DSOCatalog]) {
        self = self.filter() {
            for catalog in catalogSelection {
                for item in $0.designation {
                    if item.catalog == catalog { return true }
                }
            }
            return false
        }
    }
    mutating func filter(byConstellationSelection constellationSelection: [Constellation]) {
        self = self.filter() {
            for constellation in constellationSelection {
                if $0.constellation == constellation { return true }
            }
            return false
        }
    }
    mutating func filter(byTypeSelection typeSelection: [DSOType]) {
        self = self.filter() {
            for type in typeSelection {
                for item in $0.type {
                    if item == type { return true }
                }
            }
            return false
        }
    }
    
    mutating func filter(byBrightestMag min: Double, byDimmestMag max: Double) {
        self = self.filter() {
            if max.isNaN {
                return $0.apparentMag >= min
            }
            return $0.apparentMag >= min && $0.apparentMag <= max
        }
    }
    
    mutating func filter(byMinSize min: Double, byMaxSize max: Double) {
        self = self.filter() {
            if max.isNaN {
                return $0.arcLength >= min
            }
            return $0.arcLength >= min && $0.arcLength <= max
        }
    }
    
    mutating func filter(byMinVisScore min: Double, at location: SavedLocation, on date: Date, sunData: SunData, limitingAlt: Double) {
        self = self.filter() {
            return $0.getVisibilityScore(at: location, on: date, sunData: sunData, limitingAlt: limitingAlt) >= min
        }
    }
    
    mutating func filter(byMinMerScore min: Double, at location: SavedLocation, on date: Date, sunData: SunData) {
        self = self.filter() {
            return $0.getMeridianScore(at: location, on: date, sunData: sunData) >= min
        }
    }
}
