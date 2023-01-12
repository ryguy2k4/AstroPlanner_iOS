//
//  DeepSkyTargetArray.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/3/23.
//

import Foundation

extension Array where Element == DeepSkyTarget {
    
    func sorted(by method: SortMethod, sortDescending: Bool, location: SavedLocation, date: Date, sunData: SunData, limitingAlt: Double) -> Self {
        if sortDescending {
            switch method {
            case .visibility:
                return self.sorted(by: {$0.getVisibilityScore(at: location, on: date, sunData: sunData, limitingAlt: limitingAlt) > $1.getVisibilityScore(at: location, on: date, sunData: sunData, limitingAlt: limitingAlt)})
            case .meridian:
                return self.sorted(by: {$0.getMeridianScore(at: location, on: date, sunData: sunData) > $1.getMeridianScore(at: location, on: date, sunData: sunData)})
            case .dec:
                return self.sorted(by: {$0.dec > $1.dec})
            case .ra:
                return self.sorted(by: {$0.ra > $1.ra})
            case .magnitude:
                return self.sorted(by: {$0.apparentMag > $1.apparentMag})
            case .size:
                return self.sorted(by: {$0.arcLength > $1.arcLength})
            }
        } else {
            switch method {
            case .visibility:
                return self.sorted(by: {$0.getVisibilityScore(at: location, on: date, sunData: sunData, limitingAlt: limitingAlt) < $1.getVisibilityScore(at: location, on: date, sunData: sunData, limitingAlt: limitingAlt)})
            case .meridian:
                return self.sorted(by: {$0.getMeridianScore(at: location, on: date, sunData: sunData) < $1.getMeridianScore(at: location, on: date, sunData: sunData)})
            case .dec:
                return self.sorted(by: {$0.dec < $1.dec})
            case .ra:
                return self.sorted(by: {$0.ra < $1.ra})
            case .magnitude:
                return self.sorted(by: {$0.apparentMag < $1.apparentMag})
            case .size:
                return self.sorted(by: {$0.arcLength < $1.arcLength})
            }
        }
    }
    
    
    mutating func sort(by method: SortMethod, sortDescending: Bool, location: SavedLocation, date: Date, sunData: SunData, limitingAlt: Double) {
        self = self.sorted(by: method, sortDescending: sortDescending, location: location, date: date, sunData: sunData, limitingAlt: limitingAlt)
    }
        
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
    /*
     mutating func filter(byBrightestMag min: Double, byDimmestMag max: Double? = nil) {
         self = self.filter() {
             if let max = max {
                 return $0.apparentMag >= min && $0.apparentMag <= max
             }
             return $0.apparentMag >= min
         }
     }
     
     mutating func filter(byMinSize min: Double, byMaxSize max: Double? = nil) {
         self = self.filter() {
             if let max = max {
                 return $0.arcLength >= min && $0.arcLength <= max
             }
             return $0.arcLength >= min
         }
     }
     */
    
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
