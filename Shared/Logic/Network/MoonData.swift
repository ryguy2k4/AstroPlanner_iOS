//
//  MoonData.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/23/22.
//

import Foundation
import WeatherKit

struct MoonData {
    let phase: String
    let illuminated: Double
    let moonInterval: DateInterval
    
    init(phase: String, illuminated: Double, moonInterval: DateInterval) {
        self.phase = phase
        self.illuminated = illuminated
        self.moonInterval = moonInterval
    }
    
    init(moonDataToday: MoonEvents, moonDataTomorrow: MoonEvents, sun: SunEvents) {
        self.phase = moonDataToday.phase.rawValue
        
        // find rise
        let rise = moonDataToday.moonrise ?? moonDataTomorrow.moonrise!
        
        // if moon sets today
        if let setToday = moonDataToday.moonset {
            let set = rise < setToday ? setToday : moonDataTomorrow.moonset!
            self.moonInterval = DateInterval(start: rise, end: set)
        } else {
            self.moonInterval = DateInterval(start: rise, end: moonDataTomorrow.moonset!)
        }
                
        illuminated = MoonData.getMoonIllumination(date: moonDataToday.moonrise ?? moonDataToday.moonset!)
    }
    
    
    init(dataToday: RawMoonData, dataTomorrow: RawMoonData, on date: Date, sun: SunData) {
        self.phase = dataToday.properties.data.curphase
        self.illuminated = (Double(dataToday.properties.data.fracillum.replacingOccurrences(of: "%", with: "")) ?? .nan)/100


        var riseToday: Date? = nil
        for item in dataToday.properties.data.moondata where item.phen == "Rise" {
            riseToday = item.time.formatStringToDate(with: "HH:mm", on: date)
        }

        var setToday: Date? = nil
        for item in dataToday.properties.data.moondata where item.phen == "Set" {
            setToday = item.time.formatStringToDate(with: "HH:mm", on: date)
        }

        var riseTomorrow: Date? = nil
        for item in dataTomorrow.properties.data.moondata where item.phen == "Rise" {
            riseTomorrow = item.time.formatStringToDate(with: "HH:mm", on: date.addingTimeInterval(86400))
        }

        var setTomorrow: Date? = nil
        for item in dataTomorrow.properties.data.moondata where item.phen == "Set" {
            setTomorrow = item.time.formatStringToDate(with: "HH:mm", on: date.addingTimeInterval(86400))
        }

        // if moon does not set today, or it sets before it rises
        if setToday == nil || (riseToday != nil && setToday! < riseToday!) {
            // interval from today's rise to tomorrow's set
            moonInterval = DateInterval(start: riseToday!, end: setTomorrow!)
        }
        // if moon does not rise today, or it rises before it sets but before sunrise
        else if riseToday == nil || (riseToday! < setToday! && riseToday! < sun.astronomicalTwilightBegin) {
            // interval from tomorrow's rise to tomorrow's set
            moonInterval = DateInterval(start: riseTomorrow!, end: setTomorrow!)
        // if moon rises before it sets and it rises after sunrise
        } else {
            // interval from rise to set
            moonInterval = DateInterval(start: riseToday!, end: setToday!)
        }
    }
    
    static func getMoonIllumination(date: Date) -> Double {
        func getMoonAge(date: Date) -> Double {
            // lunar cycle length in seconds
            let cycle = 29.53058770576 * 24 * 60 * 60
            // new moon reference date
            let new2000 = 947182440.0
            let totalSecs = date.timeIntervalSince1970 - new2000
            let age = totalSecs.mod(by: cycle)
            return age / 60 / 60 / 24
        }
        
        return pow(sin(getMoonAge(date: date)/29.86 * Double.pi),2)
    }
}

extension MoonData {
    static let dummy = MoonData(phase: "Full", illuminated: 0.1, moonInterval: DateInterval(start: Date().startOfDay().addingTimeInterval(30000), duration: 30000))
}

struct RawMoonData: Decodable {
    let properties: Properties
    
    struct Properties: Decodable {
        let data: MoreData
        
        struct MoreData: Decodable {
            let curphase: String
            let day: Int
            let fracillum: String
            let moondata: [MoonTimes]
            
            struct MoonTimes: Decodable {
                let phen: String
                let time: String
            }
        }
    }
}

