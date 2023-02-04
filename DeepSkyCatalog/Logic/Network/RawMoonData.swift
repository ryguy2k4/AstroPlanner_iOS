//
//  RawMoonData.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/23/22.
//

import Foundation

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

struct MoonData {
    let phase: String
    let illuminated: Double
    let moonInterval: DateInterval
    
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
}
