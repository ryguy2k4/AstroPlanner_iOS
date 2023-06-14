//
//  SunData.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/11/22.
//

import Foundation
import WeatherKit

struct SunData {
    let astronomicalTwilightBegin: Date
    let sunrise: Date
    let ATInterval: DateInterval
    let nightInterval: DateInterval
    init(){
        self.astronomicalTwilightBegin = .now
        self.sunrise = .now
        self.ATInterval = .init(start: .now, duration: .pi)
        self.nightInterval = .init(start: .now, duration: .pi)
    }
    init(dataToday: RawSunData, dataTomorrow: RawSunData) {
        sunrise = try! Date(dataToday.results.sunrise, strategy: .iso8601)
        astronomicalTwilightBegin = try! Date(dataToday.results.astronomical_twilight_begin, strategy: .iso8601)
        
        let atStart = try! Date(dataToday.results.astronomical_twilight_end, strategy: .iso8601)
        let atEnd = try! Date(dataTomorrow.results.astronomical_twilight_begin, strategy: .iso8601)
        ATInterval = DateInterval(start: atStart, end: atEnd)
        
        let nightStart = try! Date(dataToday.results.sunset, strategy: .iso8601)
        let nightEnd = try! Date(dataTomorrow.results.sunrise, strategy: .iso8601)
        nightInterval = DateInterval(start: nightStart, end: nightEnd)
    }
    
    init(astronomicalTwilightBegin: Date, sunrise: Date, ATInterval: DateInterval, nightInterval: DateInterval) {
        self.astronomicalTwilightBegin = astronomicalTwilightBegin
        self.sunrise = sunrise
        self.ATInterval = ATInterval
        self.nightInterval = nightInterval
    }
    
    init(sunEventsToday: SunEvents, sunEventsTomorrow: SunEvents, timezone: TimeZone) {
        astronomicalTwilightBegin = sunEventsToday.astronomicalDawn!
        sunrise = sunEventsToday.sunrise!
        ATInterval = DateInterval(start: sunEventsToday.astronomicalDusk!, end: sunEventsTomorrow.astronomicalDawn!)
        nightInterval = DateInterval(start: sunEventsToday.sunset!, end: sunEventsTomorrow.sunrise!)
    }
}

struct RawSunData: Decodable {
    let results: Results
    
    struct Results: Decodable {
        let sunrise: String
        let sunset: String
        let astronomical_twilight_begin: String
        let astronomical_twilight_end: String
    }
}
