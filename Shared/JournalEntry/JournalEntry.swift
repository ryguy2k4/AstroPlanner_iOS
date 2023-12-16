//
//  JournalEntry.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/28/23.
//

import Foundation
import SwiftData
import WeatherKit

class JournalEntry: Identifiable {
    let id = UUID()
    var targetSet: [JournalTargetPlan]
    var setupInterval: DateInterval
    var weather: [HourWeather]
    var moonIllumination: Double
    var location: JournalLocation
    var gear: JournalImagingPreset
    var tags: [JournalTags]
    
    init(targetSet: [JournalTargetPlan], setupInterval: DateInterval, weather: [HourWeather], moonIllumination: Double, location: JournalLocation, gear: JournalImagingPreset, tags: [JournalTags]) {
        self.targetSet = targetSet
        self.setupInterval = setupInterval
        self.weather = weather
        self.moonIllumination = moonIllumination
        self.location = location
        self.gear = gear
        self.tags = tags
    }
    
//    init(info: [String]?, log: [String]?, plan: CaptureSequenceList?) {
//        self.location = nil
//        self.weather = nil
//        self.gear = nil
//        self.seasonScore = nil
//        self.visibilityScore = nil
//        self.tags = []
//        
//        // Extract from log file
//        if let log = log {
//            
//            let formatter = DateFormatter()
//            formatter.timeZone = .current
//            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//            
//            let formatter2 = DateFormatter()
//            formatter2.timeZone = .current
//            formatter2.dateFormat = "yyyy-MM-dd"
//            
//            // extract setup interval
//            let startString = String(log[3].trimmingCharacters(in: .punctuationCharacters).prefix(19))
//            let endString = String(log.last(where: {$0.prefix(19).contains("T")})!.prefix(19))
//            let setupStart = formatter.date(from: startString)
//            let setupEnd = formatter.date(from: endString)
//            if let start = setupStart, let end = setupEnd {
//                self.setupInterval = DateInterval(start: start, end: end)
//
//            } else {
//                self.setupInterval = nil
//                print("FAILED")
//            }
//            
//            // extract imaging interval
//            let imageStart = log.first(where: {$0.contains("Starting Category: Camera, Item: TakeExposure")})?.prefix(19)
//            let imageEnd = log.last(where: {$0.contains("Finishing Category: Camera, Item: TakeExposure")})?.prefix(19)
//            if let imageStart = imageStart, let imageStart = formatter.date(from: String(imageStart)), let imageEnd = imageEnd, let imageEnd = formatter.date(from: String(imageEnd)) {
//                self.imagingInterval = DateInterval(start: imageStart, end: imageEnd)
//            } else {
//                self.imagingInterval = nil
//            }
//            
//        } else {
//            self.setupInterval = nil
//            self.imagingInterval = nil
//        }
//        
//        // Extract from Image Plan
//        if let plan = plan {
//            self.imagePlan = plan.captureSequences.map({JournalImagePlan(sequence: $0)})
//            
//            // extract target
//            if let target = DeepSkyTargetList.allTargets.filteredBySearch(plan.targetPlanName).first {
//                self.target = .init(targetID: .catalog(id: target.id))
//            } else {
//                self.target = .init(targetID: .custom(name: plan.targetPlanName))
//            }
//        } else {
//            self.imagePlan = nil
//            self.target = nil
//        }
//    }
}

//extension JournalEntry: Encodable {
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(targetID, forKey: .targetID)
//        try container.encode(setupInterval, forKey: .setupInterval)
//        try container.encode(imagingInterval, forKey: .imagingInterval)
//        try container.encode(location, forKey: .location)
//        try container.encode(gear, forKey: .gear)
//        try container.encode(weather, forKey: .weather)
//        try container.encode(visibilityScore, forKey: .visibilityScore)
//        try container.encode(seasonScore, forKey: .seasonScore)
//        try container.encode(moonIllumination, forKey: .moonIllumination)
//        try container.encode(imagePlan, forKey: .imagePlan)
//    }
//    
//    enum CodingKeys: String, CodingKey {
//        case targetID, setupInterval, imagingInterval, location, gear, weather, visibilityScore, seasonScore, moonIllumination, imagePlan
//    }
//}

struct JournalTargetPlan: Encodable {
    var target: JournalTarget?
    var imagingInterval: DateInterval?
    var visibilityScore: Double?
    var seasonScore: Double?
    var imagePlan: JournalImagePlan?
}

struct JournalImagePlan: Encodable, Hashable {
    var imageType: ImageType
    var filterName: String
    var exposureTime: Int
//    var binning:
    var gain: Int
    var offset: Int
    var ccdTemp: Double
    var numCaptured: Int
    var numUsable: Int
    
    enum ImageType: String, Encodable {
        case light = "Light"
        case flat = "Flat"
        case dark = "Dark"
        case offset = "Offset"
    }
}

struct JournalTarget: Encodable {
    var targetID: TargetID
    var centerRA: Double?
    var centerDEC: Double?
    var rotation: Double?
    
    enum TargetID: Encodable {
        case catalog(id: UUID)
        case custom(name: String)
    }
}

struct JournalLocation: Encodable {
    var latitude: Double
    var longitude: Double
    var elevation: Double
    var bortle: Int
    
    init(latitude: Double, longitude: Double, elevation: Double, bortle: Int) {
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
        self.bortle = bortle
    }
}

struct JournalImagingPreset: Encodable {
    var focalLength: Double?
    var pixelSize: Double?
    var resolutionLength: Int?
    var resolutionWidth: Int?
    
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
