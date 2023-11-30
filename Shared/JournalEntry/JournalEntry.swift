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
    var date: Date
    var targetID: UUID
    
    // from log file
    var setupInterval: DateInterval?
    var imagingInterval: DateInterval?
    
    // from saved locations
    var location: Location?
    
    // from saved presets
//    var gear: ImagingPreset?
    
    // from weatherkit
    var weather: Forecast<HourWeather>?
    
    //from info.txt
    var legacyWeather: LegacyWeather?
    
    // from plan.xml
    var imagePlan: CaptureSequenceList?
    
    struct LegacyWeather: Codable {
        var tempF: Int
        var tempC: Int
        var wind: Int
    }
    
    init() {
        self.date = .now
        self.targetID = UUID()
        self.setupInterval = nil
        self.imagingInterval = nil
        self.location = nil
        self.weather = nil
        self.legacyWeather = nil
        self.imagePlan = nil
    }
    
    init(info: [String]?, log: [String]?, plan: CaptureSequenceList?) {
        self.location = nil
        self.weather = nil
        
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
            
            // extract date
            let formatter = DateFormatter()
            formatter.timeZone = .current
            formatter.dateFormat = "yyyy-MM-dd"
            self.date = formatter.date(from: info[1].replacingOccurrences(of: "# ", with: "")) ?? .distantPast
            
            // extract target
            if let target = DeepSkyTargetList.allTargets.filteredBySearch(info[0].replacingOccurrences(of: "# ", with: "")).first {
                self.targetID = target.id
            } else {
                self.targetID = UUID()
            }
            
        } else {
            self.legacyWeather = nil
            self.date = .distantPast
            self.targetID = UUID()
        }
        
        // Extract from log file
        if let log = log {
            
            let formatter = DateFormatter()
            formatter.timeZone = .current
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            // extract setup interval
            let startString = String(log[3].trimmingCharacters(in: .punctuationCharacters).prefix(19))
            let endString = String(log[log.endIndex - 2].prefix(19))
            let setupStart = formatter.date(from: startString)
            let setupEnd = formatter.date(from: endString)
            if let start = setupStart, let end = setupEnd {
                self.setupInterval = DateInterval(start: start, end: end)
            } else {
                self.setupInterval = nil
            }
            
            // extract imaging interval
            let imageStart = log.first(where: {$0.contains("Starting Category: Camera, Item: TakeExposure")})?.prefix(19)
            let imageEnd = log.last(where: {$0.contains("Finishing Category: Camera, Item: TakeExposure")})?.prefix(19)
            if let imageStart = imageStart, let imageStart = formatter.date(from: String(imageStart)), let imageEnd = imageEnd, let imageEnd = formatter.date(from: String(imageEnd)) {
                self.imagingInterval = DateInterval(start: imageStart, end: imageEnd)
            }
            
        } else {
            self.setupInterval = nil
            self.imagingInterval = nil
        }
        
        // Extract from Image Plan
        if let plan = plan {
            self.imagePlan = plan
        } else {
            self.imagePlan = nil
        }
    }
}

extension JournalEntry: Codable {
    enum CodingKeys: String, CodingKey {
        case date, targetID, setupInterval, location, weather, legacyWeather, imagePlan
    }
}
