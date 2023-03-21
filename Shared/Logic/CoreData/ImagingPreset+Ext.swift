//
//  ImagingPreset+Computed.swift
//  DeepSkyCatalog 
//
//  Created by Ryan Sponzilli on 3/13/23.
//

import Foundation

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
