//
//  File.swift
//  DeepSkyCatalog 
//
//  Created by Ryan Sponzilli on 11/28/23.
//

import Foundation
import SwiftData
import WeatherKit

@Model class JournalEntry: Hashable, Identifiable {
    let id = UUID()
    
    // identifying information
    var targetID: UUID
    
    // from log file
    var setupInterval: DateInterval?
    var imagingInterval: DateInterval?
    
    // from plan.xml
    var imagePlan: [JournalImagePlan]?
    var guided: Bool
    
    // weatherkit / calculables
    var weather: [HourWeather]?
    var visibilityScore: Double?
    var seasonScore: Double?
    var moonIllumination: Double?
    
    // relationships
    var location: SavedLocation?
    var gear: ImagingPreset?
    
    // custom info
    var tags: [JournalTags]
    var projects: [ProjectEntry]
    
    enum JournalTags: Codable {
        case meridianFlipFailed
        case guidingFailed
        case dewRuinedImages
    }
    
    struct JournalImagePlan: Codable, Hashable {
        var filterName: String
        var exposureTime: Int
        var totalExposureCount: Int
        var progressExposureCount: Int
        
        init(sequence: CaptureSequenceList.CaptureSequence) {
            self.filterName = sequence.filterName
            self.exposureTime = sequence.exposureTime
            self.progressExposureCount = sequence.progressExposureCount
            self.totalExposureCount = sequence.totalExposureCount
        }
        
        init(filterName: String, exposureTime: Int, totalExposureCount: Int, progressExposureCount: Int) {
            self.filterName = filterName
            self.exposureTime = exposureTime
            self.totalExposureCount = totalExposureCount
            self.progressExposureCount = progressExposureCount
        }
    }
    
    init(info: [String]?, log: [String]?, plan: CaptureSequenceList?) {
        self.location = nil
        self.weather = nil
        self.gear = nil
        self.seasonScore = nil
        self.visibilityScore = nil
        self.guided = false
        self.tags = []
        self.projects = []
        
        // Extract from log file
        if let log = log {
            
            let formatter = DateFormatter()
            formatter.timeZone = .current
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            let formatter2 = DateFormatter()
            formatter2.timeZone = .current
            formatter2.dateFormat = "yyyy-MM-dd"
            
            // extract setup interval
            let startString = String(log[3].trimmingCharacters(in: .punctuationCharacters).prefix(19))
            let endString = String(log.last(where: {$0.prefix(19).contains("T")})!.prefix(19))
            let setupStart = formatter.date(from: startString)
            let setupEnd = formatter.date(from: endString)
            if let start = setupStart, let end = setupEnd {
                self.setupInterval = DateInterval(start: start, end: end)

            } else {
                self.setupInterval = nil
                print("FAILED")
            }
            
            // extract imaging interval
            let imageStart = log.first(where: {$0.contains("Starting Category: Camera, Item: TakeExposure")})?.prefix(19)
            let imageEnd = log.last(where: {$0.contains("Finishing Category: Camera, Item: TakeExposure")})?.prefix(19)
            if let imageStart = imageStart, let imageStart = formatter.date(from: String(imageStart)), let imageEnd = imageEnd, let imageEnd = formatter.date(from: String(imageEnd)) {
                self.imagingInterval = DateInterval(start: imageStart, end: imageEnd)
            } else {
                self.imagingInterval = nil
            }
            
        } else {
            self.setupInterval = nil
            self.imagingInterval = nil
        }
        
        // Extract from Image Plan
        if let plan = plan {
            self.imagePlan = plan.captureSequences.map({Self.JournalImagePlan(sequence: $0)})
            
            // extract target
            if let target = DeepSkyTargetList.allTargets.filteredBySearch(plan.targetName).first {
                self.targetID = target.id
            } else {
                self.targetID = UUID()
            }
        } else {
            self.imagePlan = nil
            self.targetID = UUID()
        }
    }
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
