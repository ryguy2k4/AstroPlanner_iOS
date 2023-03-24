//
//  Location.swift
//  DeepSkyCatalog 
//
//  Created by Ryan Sponzilli on 3/20/23.
//

import Foundation
import CoreLocation

struct Location: Hashable {
    let latitude: Double
    let longitude: Double
    let timezone: TimeZone
    
    let source: LocationSource
    
    var name: String {
        switch source {
        case .current:
            return "Current Location"
        case .saved(let name):
            return name
        }
    }
    
    var clLocation: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    enum LocationSource: Hashable {
        case current
        case saved(String)
    }
    
    init(saved: SavedLocation) {
        self.latitude = saved.latitude
        self.longitude = saved.longitude
        self.timezone = TimeZone(identifier: saved.timezone ?? "") ?? .gmt
        self.source = .saved(saved.name!)
    }
    
    init(current: CLLocation) {
        self.latitude = current.coordinate.latitude
        self.longitude = current.coordinate.longitude
        self.timezone = Calendar.current.timeZone
        self.source = .current
    }
}
