//
//  File.swift
//  DeepSkyCatalog 
//
//  Created by Ryan Sponzilli on 11/28/23.
//

import Foundation
import WeatherKit


struct JournalEntry {
    // identifying information
    var targetID: UUID
    var targetName: String
    
    // string interpretations
    var dateString: String
    var setupStartString: String
    var setupEndString: String
    var imageStartString: String
    var imageEndString: String
    
    // from log file
    var setupInterval: DateInterval?
    var imagingInterval: DateInterval?
    
    // from saved locations
    var location: Location?
    
    // from saved presets
//    var gear: ImagingPreset?
    var gear: ImagingGear?
    
    // from weatherkit
    var weather: JournalWeather?
    
    // calculables
    var visibilityScore: Double?
    var seasonScore: Double?
    var targetType: TargetType?
    
    //from info.txt
    var legacyWeather: LegacyWeather?
    
    // from plan.xml
    var imagePlan: [JournalImagePlan]?
    
    struct LegacyWeather: Codable {
        var tempF: Int
        var tempC: Int
        var wind: Int
    }
    
    enum ImagingGear: String, CaseNameCodable, CaseIterable {
        case zenithstar61 = "Z61"
        case celestron6SE = "6SE"
    }
    
    struct JournalWeather: Codable {
        var wind: Double
        var tempC: Double
        var cloudCover: Double
        var dewPoint: Double
        var moonIllumination: Double
    
        init(forecast: Forecast<HourWeather>, moonIllumination: Double) {
            self.wind = forecast.forecast.map({$0.wind.speed.converted(to: .milesPerHour).value}).mean()
            self.tempC = forecast.forecast.map({$0.temperature.converted(to: .fahrenheit).value}).mean()
            self.cloudCover = forecast.forecast.map({$0.cloudCover}).mean()
            self.dewPoint = forecast.forecast.map({$0.dewPoint.converted(to: .fahrenheit).value}).mean()
            self.moonIllumination = moonIllumination
        }
    }
    
    struct JournalImagePlan: Codable, Hashable {
        var filterName: String
        var exposureTime: Int
        var totalExposureCount: Int
        var progressExposureCount: Int
        
        init(sequence: CaptureSequenceList.CaptureSequence) {
            self.filterName = sequence.filterType.name
            self.exposureTime = sequence.exposureTime
            self.progressExposureCount = sequence.progressExposureCount
            self.totalExposureCount = sequence.totalExposureCount
        }
    }
    
    init(info: [String]?, log: [String]?, plan: CaptureSequenceList?) {
        self.location = nil
        self.weather = nil
        self.gear = nil
        self.seasonScore = nil
        self.visibilityScore = nil
        
        // Extract from info.txt
        if let unwrappedInfo = info {
            let info = unwrappedInfo.map({$0.trimmingCharacters(in: .newlines)})
            
            // extract legacy weather
            let tempF = info.first(where: {$0.starts(with: "Temperature(F)")})?.replacingOccurrences(of: "Temperature(F): ", with: "")
            let tempC = info.first(where: {$0.starts(with: "Temperature(C)")})?.replacingOccurrences(of: "Temperature(C): ", with: "")
            let wind = info.first(where: {$0.starts(with: "Wind")})?.replacingOccurrences(of: "Wind (mph): ", with: "")
            if let tempF = tempF, let tf = Int(tempF), let tempC = tempC, let tc = Int(tempC), let wind = wind, let w = Int(wind) {
                self.legacyWeather = LegacyWeather(tempF: tf, tempC: tc, wind: w)
            } else {
                self.legacyWeather = nil
            }
            
        } else {
            self.legacyWeather = nil
        }
        
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
            let endString = String(log[log.endIndex - 2].prefix(19))
            let setupStart = formatter.date(from: startString)
            let setupEnd = formatter.date(from: endString)
            if let start = setupStart, let end = setupEnd {
                self.setupInterval = DateInterval(start: start, end: end)
                self.setupStartString = formatter.string(from: start)
                self.setupEndString = formatter.string(from: end)
                self.dateString = formatter2.string(from: start)

            } else {
                self.setupInterval = nil
                self.setupStartString = "n/a"
                self.setupEndString = "n/a"
                self.dateString = "n/a"
                print("FAILED")
            }
            
            // extract imaging interval
            let imageStart = log.first(where: {$0.contains("Starting Category: Camera, Item: TakeExposure")})?.prefix(19)
            let imageEnd = log.last(where: {$0.contains("Finishing Category: Camera, Item: TakeExposure")})?.prefix(19)
            if let imageStart = imageStart, let imageStart = formatter.date(from: String(imageStart)), let imageEnd = imageEnd, let imageEnd = formatter.date(from: String(imageEnd)) {
                self.imagingInterval = DateInterval(start: imageStart, end: imageEnd)
                self.imageStartString = formatter.string(from: imageStart)
                self.imageEndString = formatter.string(from: imageEnd)
            } else {
                self.imagingInterval = nil
                self.imageStartString = "n/a"
                self.imageEndString = "n/a"
            }
            
        } else {
            self.setupInterval = nil
            self.imagingInterval = nil
            self.setupStartString = "n/a"
            self.setupEndString = "n/a"
            self.imageStartString = "n/a"
            self.imageEndString = "n/a"
            self.dateString = "n/a"
        }
        
        // Extract from Image Plan
        if let plan = plan {
            self.imagePlan = plan.captureSequences.map({Self.JournalImagePlan(sequence: $0)})
            
            // extract target
            if let target = DeepSkyTargetList.allTargets.filteredBySearch(plan.targetName).first {
                self.targetID = target.id
                let dso = DeepSkyTargetList.allTargets.first(where: {$0.id == target.id})
                self.targetName = dso?.name?.first ?? dso?.defaultName ?? "n/a"
                self.targetType = dso?.type ?? nil
            } else {
                self.targetID = UUID()
                self.targetName = "n/a"
            }
        } else {
            self.imagePlan = nil
            self.targetID = UUID()
            self.targetName = "n/a"
        }
    }
}

extension JournalEntry: Codable {}
