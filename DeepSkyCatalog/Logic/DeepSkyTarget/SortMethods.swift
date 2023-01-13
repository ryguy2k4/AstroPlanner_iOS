//
//  SortMethods.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/12/23.
//

import Foundation

enum SortMethod: CaseIterable, Hashable, Identifiable {
    static var allCases: [SortMethod] = [.visibility, .meridian, .dec, .ra, .magnitude, .size]
    
    var id: Self { self }
    case visibility
    case meridian
    case dec
    case ra
    case magnitude
    case size
    case catalog(DSOCatalog)
    
    var info: (name: String, icon: String) {
        switch self {
        case .visibility:
            return ("Visibility", "eye.fill")
        case .meridian:
            return ("Meridian", "arrow.right.and.line.vertical.and.arrow.left")
        case .dec:
            return ("Dec", "arrow.up.arrow.down")
        case .ra:
            return ("RA", "arrow.right.arrow.left")
        case .magnitude:
            return ("Magnitude", "sun.min.fill")
        case .size:
            return ("Size", "arrow.up.left.and.arrow.down.right")
        case .catalog:
            return ("Catalog", "list.star")
        }
    }
}

extension Array where Element == DeepSkyTarget {
    
    // utilize reverse() method instead of all the if-else for sortDescending
    
    func sortedByVisibility(descending: Bool, location: SavedLocation, date: Date, sunData: SunData, limitingAlt: Double) -> Self {
        if descending {
            return self.sorted(by: {$0.getVisibilityScore(at: location, on: date, sunData: sunData, limitingAlt: limitingAlt) > $1.getVisibilityScore(at: location, on: date, sunData: sunData, limitingAlt: limitingAlt)})
        } else {
            return self.sorted(by: {$0.getVisibilityScore(at: location, on: date, sunData: sunData, limitingAlt: limitingAlt) < $1.getVisibilityScore(at: location, on: date, sunData: sunData, limitingAlt: limitingAlt)})
        }
    }
    
    mutating func sortByVisibility(descending: Bool, location: SavedLocation, date: Date, sunData: SunData, limitingAlt: Double) {
        self = self.sortedByVisibility(descending: descending, location: location, date: date, sunData: sunData, limitingAlt: limitingAlt)
    }
    
    func sortedByMeridian(descending: Bool, location: SavedLocation, date: Date, sunData: SunData) -> Self {
        if descending {
            return self.sorted(by: {$0.getMeridianScore(at: location, on: date, sunData: sunData) > $1.getMeridianScore(at: location, on: date, sunData: sunData)})
        } else {
            return self.sorted(by: {$0.getMeridianScore(at: location, on: date, sunData: sunData) < $1.getMeridianScore(at: location, on: date, sunData: sunData)})
        }
    }
    
    mutating func sortByMeridian(descending: Bool, location: SavedLocation, date: Date, sunData: SunData) {
        self = self.sortedByMeridian(descending: descending, location: location, date: date, sunData: sunData)
    }
    
    func sortedByDec(descending: Bool) -> Self {
        if descending {
            return self.sorted(by: {$0.dec > $1.dec})
        } else {
            return self.sorted(by: {$0.dec < $1.dec})
        }
    }
    
    mutating func sortByDec(descending: Bool) {
        self = self.sortedByDec(descending: descending)
    }
    
    func sortedByRA(descending: Bool) -> Self {
        if descending {
            return self.sorted(by: {$0.ra > $1.ra})
        } else {
            return self.sorted(by: {$0.ra < $1.ra})
        }
    }
    
    mutating func sortByRA(descending: Bool) {
        self = self.sortedByRA(descending: descending)
    }
    
    func sortedByMagnitude(descending: Bool) -> Self {
        if descending {
            return self.sorted(by: {$0.apparentMag > $1.apparentMag})
        } else {
            return self.sorted(by: {$0.apparentMag < $1.apparentMag})
        }
    }
    
    mutating func sortByMagnitude(descending: Bool) {
        self = self.sortedByMagnitude(descending: descending)
    }
    
    func sortedBySize(descending: Bool) -> Self {
        if descending {
            return self.sorted(by: {$0.arcLength > $1.arcLength})
        } else {
            return self.sorted(by: {$0.arcLength < $1.arcLength})
        }
    }
    
    mutating func sortBySize(descending: Bool) {
        self = self.sortedBySize(descending: descending)
    }
    
    func sortedByCatalog(descending: Bool, catalog: DSOCatalog) -> Self {
        if descending {
            return self.sorted { t1, t2 in
                return t1.designation.first { des in
                    return des.catalog == catalog
                }!.number > t2.designation.first { des in
                    return des.catalog == catalog
                }!.number
            }
        } else {
            return self.sorted { t1, t2 in
                return t1.designation.first { des in
                    return des.catalog == catalog
                }!.number < t2.designation.first { des in
                    return des.catalog == catalog
                }!.number
            }
        }
    }
    
    mutating func sortByCatalog(descending: Bool, catalog: DSOCatalog) {
        self = self.sortedByCatalog(descending: descending, catalog: catalog)
    }
}
