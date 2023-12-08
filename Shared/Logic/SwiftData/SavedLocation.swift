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
    var latitude: Double = 41.8781
    var longitude: Double = 87.6298
    var name: String = "Chicago"
    var timezone: String = "CST"
    
    init(isSelected: Bool, latitude: Double, longitude: Double, name: String, timezone: String) {
        self.isSelected = isSelected
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.timezone = timezone
    }
}
