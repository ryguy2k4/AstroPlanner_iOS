//
//  SunData.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/11/22.
//

import Foundation
import WeatherKit

struct SunData: Equatable {
    
    /// An Interval from Astronomical Dusk on the current night to Astronomical Dawn on the following morning
    let ATInterval: DateInterval
    
    /// An Interval from Sunset on the current night to sunrise on the following morning
    let nightInterval: DateInterval
    
    let solarMidnight: Date
    
    static let `default`: SunData = .init()
    
    init() {
        self.ATInterval = .init(start: .now, duration: .pi)
        self.nightInterval = .init(start: .now, duration: .pi)
        self.solarMidnight = .now
    }
    
    init(dataToday: RawSunData, dataTomorrow: RawSunData) {
        let atStart = try! Date(dataToday.results.astronomical_twilight_end, strategy: .iso8601)
        let atEnd = try! Date(dataTomorrow.results.astronomical_twilight_begin, strategy: .iso8601)
        ATInterval = DateInterval(start: atStart, end: atEnd)
        
        let nightStart = try! Date(dataToday.results.sunset, strategy: .iso8601)
        let nightEnd = try! Date(dataTomorrow.results.sunrise, strategy: .iso8601)
        nightInterval = DateInterval(start: nightStart, end: nightEnd)
        
        let solarNoon = try! Date(dataToday.results.solar_noon, strategy: .iso8601)
        solarMidnight = solarNoon.addingTimeInterval(43_200)
    }
    
    init(ATInterval: DateInterval, nightInterval: DateInterval, solarMidnight: Date) {
        self.ATInterval = ATInterval
        self.nightInterval = nightInterval
        self.solarMidnight = solarMidnight
    }
    
    init(sunEventsToday: SunEvents, sunEventsTomorrow: SunEvents) {
        if let duskToday = sunEventsToday.astronomicalDusk, let dawnTomorrow = sunEventsTomorrow.astronomicalDawn, let sunsetToday = sunEventsToday.sunset, let sunriseTomorrow = sunEventsTomorrow.sunrise {
            ATInterval = DateInterval(start: duskToday, end: dawnTomorrow)
            nightInterval = DateInterval(start: sunsetToday, end: sunriseTomorrow)
        } else {
            fatalError("Nil SunEvent found")
        }
        solarMidnight = sunEventsTomorrow.solarMidnight!
    }
}

struct RawSunData: Decodable {
    let results: Results
    
    struct Results: Decodable {
        let sunrise: String
        let sunset: String
        let astronomical_twilight_begin: String
        let astronomical_twilight_end: String
        let solar_noon: String
    }
}
