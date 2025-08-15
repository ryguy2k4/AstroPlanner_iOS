//
//  ImagingPreset.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 12/4/23.
//
//

import Foundation
import SwiftData

@Model class ImagingPreset {
    var focalLength: Double = 0
    var isSelected: Bool = false
    var name: String = "New Preset"
    var pixelSize: Double = 0
    var resolutionLength: Int = 0
    var resolutionWidth: Int = 0
    
    init(focalLength: Double, isSelected: Bool, name: String, pixelSize: Double, resolutionLength: Int, resolutionWidth: Int) {
        self.focalLength = focalLength
        self.isSelected = isSelected
        self.name = name
        self.pixelSize = pixelSize
        self.resolutionLength = resolutionLength
        self.resolutionWidth = resolutionWidth
    }
}

extension ImagingPreset {
    var pixelScale: Double {
        get {
            return pixelSize / focalLength * 206.2648
        }
    }
    
    var fovLength: Double {
        get {
            return pixelScale * Double(resolutionLength) / 60
        }
    }
    
    var fovWidth: Double {
        get {
           return pixelScale * Double(resolutionWidth) / 60
        }
    }
}

extension ImagingPreset: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(focalLength, forKey: .focalLength)
        try container.encode(name, forKey: .name)
        try container.encode(pixelSize, forKey: .pixelSize)
        try container.encode(resolutionWidth, forKey: .resolutionWidth)
        try container.encode(resolutionLength, forKey: .resolutionLength)
    }
    
    enum CodingKeys: String, CodingKey {
        case focalLength, name, pixelSize, resolutionWidth, resolutionLength
    }
}
