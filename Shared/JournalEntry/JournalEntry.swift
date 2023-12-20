//
//  JournalEntry.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/28/23.
//

import Foundation
import SwiftData
import WeatherKit

class JournalEntry: Identifiable, Codable {
    let id = UUID()
    var targetSet: [JournalTargetPlan]
    var setupInterval: DateInterval?
    var weather: [HourWeather]?
    var moonIllumination: Double?
    var location: JournalLocation?
    var gear: JournalImagingPreset?
    var tags: [JournalTags]
    
    init(targetSet: [JournalTargetPlan] = [], setupInterval: DateInterval? = nil, weather: [HourWeather]? = nil, moonIllumination: Double? = nil, location: JournalLocation? = nil, gear: JournalImagingPreset? = nil, tags: [JournalTags] = []) {
        self.targetSet = targetSet
        self.setupInterval = setupInterval
        self.weather = weather
        self.moonIllumination = moonIllumination
        self.location = location
        self.gear = gear
        self.tags = tags
    }
}

struct JournalTargetPlan: Codable {
    var target: JournalTarget?
    var imagingInterval: DateInterval?
    var visibilityScore: Double?
    var seasonScore: Double?
    var imagePlan: [JournalImageSequence]?
}

struct JournalImageSequence: Codable, Hashable {
    var imageType: ImageType?
    var filterName: String?
    var exposureTime: Double?
    var binning: Binning?
    var gain: Int?
    var offset: Int?
    var ccdTemp: Double?
    var numCaptured: Int?
    var numUsable: Int?
    
    enum ImageType: String, Codable, Hashable {
        case light = "LIGHT"
        case flat = "FLAT"
        case dark = "DARK"
        case offset = "OFFSET"
    }
    
    struct Binning: Codable, Hashable {
        var x: Int
        var y: Int
    }
}

struct JournalTarget: Codable {
    var targetID: TargetID
    var centerRA: Double?
    var centerDEC: Double?
    var rotation: Double?
    
    enum TargetID: Codable {
        case catalog(id: UUID)
        case custom(name: String)
        
        init(targetName: String) {
            let id = DeepSkyTargetList.allTargets.first(where: {$0.name?.first == targetName})?.id
            if let id = id {
                self = .catalog(id: id)
            } else {
                self = .custom(name: targetName)
            }
        }
        
        var name: String {
            get {
                switch self {
                case .catalog(let id):
                    return DeepSkyTargetList.targetNameDict[id]!
                case .custom(let name):
                    return name
                }
            }
        }
    }
}

struct JournalLocation: Codable {
    var latitude: Double
    var longitude: Double
    var timezone: String
    var elevation: Double?
    var bortle: Int?
    
    init(latitude: Double, longitude: Double, timezone: String, elevation: Double? = nil, bortle: Int? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
        self.elevation = elevation
        self.bortle = bortle
    }
}

struct JournalImagingPreset: Codable {
    var focalLength: Double
    var pixelSize: Double
    var resolutionLength: Int
    var resolutionWidth: Int
    
    init(focalLength: Double, pixelSize: Double, resolutionLength: Int, resolutionWidth: Int) {
        self.focalLength = focalLength
        self.pixelSize = pixelSize
        self.resolutionLength = resolutionLength
        self.resolutionWidth = resolutionWidth
    }
    
    init(from saved: ImagingPreset) {
        self.focalLength = saved.focalLength
        self.pixelSize = saved.pixelSize
        self.resolutionLength = saved.resolutionLength
        self.resolutionWidth = saved.resolutionWidth
    }
}

enum JournalTags: Codable {
    case meridianFlipFailed
    case guidingFailed
    case dewRuinedImages
}
