//
//  Location.swift
//  DeepSkyCatalog 
//
//  Created by Ryan Sponzilli on 3/20/23.
//

import Foundation
import CoreLocation

struct Location: Hashable, Equatable, Codable {
    var name: String
    var latitude: Double
    var longitude: Double
    var timezone: TimeZone
    var elevation: Double?
    var bortle: Int?
    
    var clLocation: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    init(saved: SavedLocation) {
        self.name = saved.name
        self.latitude = saved.latitude
        self.longitude = saved.longitude
        self.timezone = TimeZone(identifier: saved.timezone) ?? .gmt
        self.elevation = saved.elevation
        self.bortle = saved.bortle
    }
    
    init(current: CLLocation) {
        self.name = "Current Location"
        self.latitude = current.coordinate.latitude
        self.longitude = current.coordinate.longitude
        self.timezone = Calendar.current.timeZone
        self.elevation = current.altitude.magnitude
        self.bortle = nil
    }
    
    init(latitude: Double, longitude: Double, timezone: TimeZone? = nil, elevation: Double? = nil, bortle: Int? = nil) {
        self.name = "Unspecified"
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone ?? .gmt
        self.elevation = elevation
        self.bortle = bortle
    }
    
    init() {
        self.name = "Unspecified"
        self.latitude = 0
        self.longitude = 0
        self.timezone = .gmt
        self.elevation = nil
        self.bortle = nil
    }
    
    static let `default`: Location = .init()
}
