//
//  SortMethods.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/12/23.
//

import Foundation

enum SortMethod: CaseIterable, Hashable, Identifiable {
    static var allCases: [SortMethod] = [.visibility, .seasonScore, .dec, .ra, .magnitude, .size]
    static var offlineCases: [SortMethod] = [.dec, .ra, .magnitude, .size]
    
    var id: Self { self }
    case visibility
    case seasonScore
    case dec
    case ra
    case magnitude
    case size
    
    var info: (name: String, icon: String) {
        switch self {
        case .visibility:
            return ("Visibility", "eye.fill")
        case .seasonScore:
            return ("Season", "calendar.circle")
        case .dec:
            return ("Dec", "arrow.up.arrow.down")
        case .ra:
            return ("RA", "arrow.right.arrow.left")
        case .magnitude:
            return ("Magnitude", "sun.min.fill")
        case .size:
            return ("Size", "arrow.up.left.and.arrow.down.right")
        }
    }
}

extension Array where Element == DeepSkyTarget {
    
    func sortedBySearch(_ searchText: String) -> Self {
        return self.sorted(by: {
            $0.description.localizedCaseInsensitiveContains(searchText) && !$1.description.localizedCaseInsensitiveContains(searchText)
        })
    }
    
    mutating func sortBySearch(_ searchText: String) {
        self = self.sortedBySearch(searchText)
    }
        
    func sortedByVisibility(location: Location, viewingInterval: DateInterval, sunData: SunData, limitingAlt: Double) -> Self {
        return self.sorted(by: {$0.getVisibilityScore(at: location, viewingInterval: viewingInterval, sunData: sunData, limitingAlt: limitingAlt) > $1.getVisibilityScore(at: location, viewingInterval: viewingInterval, sunData: sunData, limitingAlt: limitingAlt)})
    }
    
    mutating func sortByVisibility(location: Location, viewingInterval: DateInterval, sunData: SunData, limitingAlt: Double) {
        self = self.sortedByVisibility(location: location, viewingInterval: viewingInterval, sunData: sunData, limitingAlt: limitingAlt)
    }
    
    func sortedByMeridian(location: Location, date: Date, sunData: SunData) -> Self {
        return self.sorted(by: {$0.getSeasonScore(at: location, on: date, sunData: sunData) > $1.getSeasonScore(at: location, on: date, sunData: sunData)})
    }
    
    mutating func sortByMeridian(location: Location, date: Date, sunData: SunData) {
        self = self.sortedByMeridian(location: location, date: date, sunData: sunData)
    }
    
    func sortedByDec() -> Self {
        return self.sorted(by: {$0.dec > $1.dec})
    }
    
    mutating func sortByDec() {
        self = self.sortedByDec()
    }
    
    func sortedByRA() -> Self {
        return self.sorted(by: {$0.ra > $1.ra})
    }
    
    mutating func sortByRA() {
        self = self.sortedByRA()
    }
    
    func sortedByMagnitude() -> Self {
        return self.sorted(by: {$0.apparentMag ?? .greatestFiniteMagnitude > $1.apparentMag ?? .greatestFiniteMagnitude})
    }
    
    mutating func sortByMagnitude() {
        self = self.sortedByMagnitude()
    }
    
    func sortedBySize() -> Self {
        return self.sorted(by: {$0.arcLength > $1.arcLength})
    }
    
    mutating func sortBySize() {
        self = self.sortedBySize()
    }
    
    func sortedByCatalog(catalog: TargetCatalog) -> Self {
        return self.sorted { t1, t2 in
            return t1.designation.first { des in
                return des.catalog == catalog
            }!.number > t2.designation.first { des in
                return des.catalog == catalog
            }!.number
        }
    }
    
    mutating func sortByCatalog(catalog: TargetCatalog) {
        self = self.sortedByCatalog(catalog: catalog)
    }
}
