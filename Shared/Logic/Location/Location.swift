//
//  Location.swift
//  DeepSkyCatalog 
//
//  Created by Ryan Sponzilli on 3/20/23.
//

import Foundation
import CoreLocation

struct Location: Hashable, Equatable, Codable {
    var latitude: Double
    var longitude: Double
    var timezone: TimeZone
    var elevation: Double?
    var bortle: Int?
    
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
    
    enum LocationSource: Hashable, Codable {
        case current
        case saved(String)
    }
    
    init(saved: SavedLocation) {
        self.latitude = saved.latitude
        self.longitude = saved.longitude
        self.timezone = TimeZone(identifier: saved.timezone) ?? .gmt
        self.elevation = saved.elevation
        self.bortle = saved.bortle
        self.source = .saved(saved.name)
    }
    
    init(current: CLLocation) {
        self.latitude = current.coordinate.latitude
        self.longitude = current.coordinate.longitude
        self.timezone = Calendar.current.timeZone
        self.elevation = current.altitude.magnitude
        self.bortle = nil
        self.source = .current
    }
    
    static let `default`: Location = .init(current: CLLocation(latitude: 0, longitude: 0))
}
