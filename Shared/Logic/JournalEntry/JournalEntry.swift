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
    @Published var weather: [JournalHourWeather]?
    @Published var moonIllumination: Double?
    @Published var location: Location?
    @Published var gear: JournalGear?
    @Published var tags: Set<JournalTag>
    @Published var notes: [String]
    // Target Specific
    @Published var target: JournalTarget?
    @Published var imagingInterval: DateInterval?
    @Published var visibilityScore: Double?
    @Published var seasonScore: Double?
    @Published var images: [JournalImageSequence]?
    
    init(setupInterval: DateInterval? = nil, weather: [JournalHourWeather]? = nil, moonIllumination: Double? = nil, location: Location? = nil, gear: JournalGear? = nil, tags: Set<JournalTag> = [], notes: [String] = [], target: JournalTarget? = nil, imagingInterval: DateInterval? = nil, visibilityScore: Double? = nil, seasonScore: Double? = nil, imagePlan: [JournalImageSequence]? = nil) {
        self.setupInterval = setupInterval
        self.weather = weather
        self.moonIllumination = moonIllumination
        self.location = location
        self.gear = gear
        self.tags = tags
        self.notes = notes
        self.target = target
        self.imagingInterval = imagingInterval
        self.visibilityScore = visibilityScore
        self.seasonScore = seasonScore
        self.images = imagePlan
    }
    
    struct JournalHourWeather: Codable, Hashable {
        let date: Date
        let temperatureF: Double
        let apparentTemperatureF: Double
        let dewPointF: Double
        let cloudCover: Double
        let windMPH: Double
        
        init(weather: HourWeather) {
            self.date = weather.date
            self.temperatureF = weather.temperature.converted(to: .fahrenheit).value
            self.dewPointF = weather.dewPoint.converted(to: .fahrenheit).value
            self.cloudCover = weather.cloudCover
            self.windMPH = weather.wind.speed.converted(to: .milesPerHour).value
            self.apparentTemperatureF = weather.apparentTemperature.converted(to: .fahrenheit).value
            
        }
    }
    
    /**
     This struct defines a group of images taken by a certain filter
     All the images that this set represents have the same filterName, exposureTime, binning, gain, and offset
     The ccdTemp and airmass of each image will vary, so they are all contained in an array
     */
    struct JournalImageSequence: Codable, Hashable, Identifiable {
        var id = UUID()
        // Group Image Specs
        var filterName: String?
        var exposureTime: Double?
        var binning: Int?
        var gain: Int?
        var offset: Int?
        
        // Individual Image Specs
        var ccdTemp: [Double]?
        var airmass: [Double]?
        
        // Number from NINA/APT Log
        var numCaptured: Int?
        
        // Number from Image Files imported
        var numSaved: Int?
    }
    
    /* IDEA
     Question: Log only usable images, or all images captured?
    
     Logging only usable images
     - PRO: all historical data is still intact
     - PRO: data structure is easier to implement
     - CON: missing out on tracking some data
     
     
     Logging all images captured
     - PRO: allow analysis of factors that caused an image to be usable or unusable (temp, time, weather, airmass, etc)
     - PRO: data structure would be more elegant
     - CON: data structure would be larger and more complex
     - CON: difficult to use with SwiftData
     - CON: for all past sessions, I will be missing data
     - CON: would have to indicate which images were used and which were not, probably manually (or pixinsight log maybe)
     
     
    struct JournalImagePlan {
        var images: [JournalImage]
        var numCaptured: Int?
        var numUsable: Int?
    }
    
    struct JournalImage {
        var dateTime: Date
        var filterName: String?
        var exposureTime: Double?
        var binX: Int?
        var binY: Int?
        var gain: Int?
        var offset: Int?
        var ccdTemp: Double?
        var airmass: Double?
    }
    */

    struct JournalTarget: Codable {
        var targetID: TargetID?
        var centerRA: Double?
        var centerDEC: Double?
        var rotation: Double?
        
        enum TargetID: Codable, Equatable {
            case catalog(id: UUID)
            case custom(name: String)
            
            init?(targetName: String?) {
                if let targetName = targetName {
                    if let id = DeepSkyTargetList.allTargets.first(where: {$0.name?.first == targetName})?.id {
                        self = .catalog(id: id)
                    } else {
                        self = .custom(name: targetName)
                    }
                } else {
                    return nil
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
        var focalLength: Double?
        var pixelSize: Double?
        var resolutionLength: Int?
        var resolutionWidth: Int?
        // Qualitative
        var telescopeName: String?
        var filterWheelName: String?
        var mountName: String?
        var cameraName: String?
        var captureSoftware: String?
        
        static let `default`: JournalGear = JournalGear()
        
        init(focalLength: Double? = nil, pixelSize: Double? = nil, resolutionLength: Int? = nil, resolutionWidth: Int? = nil, telescopeName: String? = nil, filterWheelName: String? = nil, mountName: String? = nil, cameraName: String? = nil, captureSoftware: String? = nil) {
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

    enum JournalTag: String, Codable, CaseIterable {
        case meridianFlipFailed
        case guidingFailed
        case dewRuinedImages
        case incorrectUsableCaptured
        case noLogFile
        case targetMosaic
        case multiTargetNight
        case unusedData
        case noFlats
        case unverified
        case verified1
    }
    
    
    
    // Codable Implementation
    enum CodingKeys: String, CodingKey {
        case setupInterval, weather, moonIllumination, location, gear, tags, notes, target, imagingInterval, visibilityScore, seasonScore, imagePlan
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.setupInterval = try container.decode(DateInterval?.self, forKey: .setupInterval)
        self.weather = try container.decode([JournalHourWeather]?.self, forKey: .weather)
        self.moonIllumination = try container.decode(Double?.self, forKey: .moonIllumination)
        self.location = try container.decode(Location?.self, forKey: .location)
        self.gear = try container.decode(JournalGear?.self, forKey: .gear)
        self.tags = try container.decode(Set<JournalTag>.self, forKey: .tags)
        self.notes = try container.decode([String].self, forKey: .notes)
        self.target = try container.decode(JournalTarget?.self, forKey: .target)
        self.imagingInterval = try? container.decode(DateInterval?.self, forKey: .imagingInterval)
        self.visibilityScore = try container.decode(Double?.self, forKey: .visibilityScore)
        self.seasonScore = try container.decode(Double?.self, forKey: .seasonScore)
        self.images = try container.decode([JournalImageSequence]?.self, forKey: .imagePlan)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(setupInterval, forKey: .setupInterval)
        try container.encode(weather, forKey: .weather)
        try container.encode(moonIllumination, forKey: .moonIllumination)
        try container.encode(location, forKey: .location)
        try container.encode(gear, forKey: .gear)
        try container.encode(tags, forKey: .tags)
        try container.encode(notes, forKey: .notes)
        try container.encode(target, forKey: .target)
        try container.encode(imagingInterval, forKey: .imagingInterval)
        try container.encode(visibilityScore, forKey: .visibilityScore)
        try container.encode(seasonScore, forKey: .seasonScore)
        try container.encode(images, forKey: .imagePlan)
    }
}

