//
//  SavedLocation.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 12/4/23.
//
//

import Foundation
import SwiftData

@Model class SavedLocation {
    var isSelected: Bool = false
    
    var name: String = "Chicago"
    var latitude: Double = 41.8781
    var longitude: Double = 87.6298
    var timezone: String = "CST"
    var elevation: Double? = nil
    var bortle: Int? = nil
    
    init(isSelected: Bool, latitude: Double, longitude: Double, name: String, timezone: String, elevation: Double? = nil, bortle: Int? = nil) {
        self.isSelected = isSelected
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.timezone = timezone
        self.elevation = elevation
        self.bortle = bortle
    }
}

extension SavedLocation: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(name, forKey: .name)
        try container.encode(timezone, forKey: .timezone)
        try container.encode(elevation, forKey: .elevation)
        try container.encode(bortle, forKey: .bortle)
    }
    
    enum CodingKeys: String, CodingKey {
        case latitude, longitude, name, timezone, bortle, elevation
    }
}
