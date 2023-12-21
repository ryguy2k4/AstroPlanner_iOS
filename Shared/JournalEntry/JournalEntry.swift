//
//  JournalEntry.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/28/23.
//

import Foundation
import SwiftData
import WeatherKit

class JournalEntry: Identifiable, Encodable {
    let id = UUID()
    // Session Specific
    var setupInterval: DateInterval?
    var weather: [HourWeather]?
    var moonIllumination: Double?
    var location: Location?
    var gear: JournalImagingPreset?
    var tags: [JournalTags]
    // Target Specific
    var target: JournalTarget?
    var imagingInterval: DateInterval?
    var visibilityScore: Double?
    var seasonScore: Double?
    var imagePlan: [JournalImageSequence]?
    
    init(setupInterval: DateInterval? = nil, weather: [HourWeather]? = nil, moonIllumination: Double? = nil, location: Location? = nil, gear: JournalImagingPreset? = nil, tags: [JournalTags] = [], target: JournalTarget? = nil, imagingInterval: DateInterval? = nil, visibilityScore: Double? = nil, seasonScore: Double? = nil, imagePlan: [JournalImageSequence]? = nil) {
        self.setupInterval = setupInterval
        self.weather = weather
        self.moonIllumination = moonIllumination
        self.location = location
        self.gear = gear
        self.tags = tags
        self.target = target
        self.imagingInterval = imagingInterval
        self.visibilityScore = visibilityScore
        self.seasonScore = seasonScore
        self.imagePlan = imagePlan
    }
}

struct JournalImageSequence: Codable, Hashable {
    var imageType: String?
    var filterName: String?
    var exposureTime: Double?
    var binX: Int?
    var binY: Int?
    var gain: Int?
    var offset: Int?
    var numCaptured: Int?
    var numUsable: Int?
    var ccdTemp: [Double]?
    var airmass: [Double]?
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
