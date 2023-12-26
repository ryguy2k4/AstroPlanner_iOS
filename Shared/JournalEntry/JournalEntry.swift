//
//  JournalEntry.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/28/23.
//

import Foundation
import SwiftData
import WeatherKit

final class JournalEntry: Identifiable, ObservableObject, Codable {
    let id = UUID()
    // Session Specific
    @Published var setupInterval: DateInterval?
    @Published var weather: [HourWeather]?
    @Published var moonIllumination: Double?
    @Published var location: Location?
    @Published var gear: JournalGear?
    @Published var tags: [JournalTags]
    // Target Specific
    @Published var target: JournalTarget?
    @Published var imagingInterval: DateInterval?
    @Published var visibilityScore: Double?
    @Published var seasonScore: Double?
    @Published var imagePlan: [JournalImageSequence]?
    
    init(setupInterval: DateInterval? = nil, weather: [HourWeather]? = nil, moonIllumination: Double? = nil, location: Location? = nil, gear: JournalGear? = nil, tags: [JournalTags] = [], target: JournalTarget? = nil, imagingInterval: DateInterval? = nil, visibilityScore: Double? = nil, seasonScore: Double? = nil, imagePlan: [JournalImageSequence]? = nil) {
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
        
        enum TargetID: Codable, Equatable {
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

    struct JournalGear: Codable, Hashable {
        // Quantitative
        var focalLength: Double
        var pixelSize: Double
        var resolutionLength: Int
        var resolutionWidth: Int
        // Qualitative
        var telescopeName: String?
        var filterWheelName: String?
        var mountName: String?
        var cameraName: String?
        var captureSoftware: String?
        
        static let `default`: JournalGear = .init(focalLength: 0, pixelSize: 0, resolutionLength: 0, resolutionWidth: 0)
        
        init(focalLength: Double, pixelSize: Double, resolutionLength: Int, resolutionWidth: Int, telescopeName: String? = nil, filterWheelName: String? = nil, mountName: String? = nil, cameraName: String? = nil, captureSoftware: String? = nil) {
            self.focalLength = focalLength
            self.pixelSize = pixelSize
            self.resolutionLength = resolutionLength
            self.resolutionWidth = resolutionWidth
            self.telescopeName = telescopeName
            self.filterWheelName = filterWheelName
            self.mountName = mountName
            self.cameraName = cameraName
            self.captureSoftware = captureSoftware
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
    
    enum CodingKeys: String, CodingKey {
        case setupInterval, weather, moonIllumination, location, gear, tags, target, imagingInterval, visibilityScore, seasonScore, imagePlan
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.setupInterval = try container.decode(DateInterval?.self, forKey: .setupInterval)
        self.weather = try container.decode([HourWeather]?.self, forKey: .weather)
        self.moonIllumination = try container.decode(Double?.self, forKey: .moonIllumination)
        self.location = try container.decode(Location?.self, forKey: .location)
        self.gear = try container.decode(JournalGear?.self, forKey: .gear)
        self.tags = try container.decode([JournalTags].self, forKey: .tags)
        self.target = try container.decode(JournalTarget?.self, forKey: .target)
        self.imagingInterval = try? container.decode(DateInterval?.self, forKey: .imagingInterval)
        self.visibilityScore = try container.decode(Double?.self, forKey: .visibilityScore)
        self.seasonScore = try container.decode(Double?.self, forKey: .seasonScore)
        self.imagePlan = try container.decode([JournalImageSequence]?.self, forKey: .imagePlan)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(setupInterval, forKey: .setupInterval)
        try container.encode(weather, forKey: .weather)
        try container.encode(moonIllumination, forKey: .moonIllumination)
        try container.encode(location, forKey: .location)
        try container.encode(gear, forKey: .gear)
        try container.encode(tags, forKey: .tags)
        try container.encode(target, forKey: .target)
        try container.encode(imagingInterval, forKey: .imagingInterval)
        try container.encode(visibilityScore, forKey: .visibilityScore)
        try container.encode(seasonScore, forKey: .seasonScore)
        try container.encode(imagePlan, forKey: .imagePlan)
    }
}

