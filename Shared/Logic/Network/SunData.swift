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
    
    init(dataToday: RawSunData, dataTomorrow: RawSunData) {
        sunrise = dataToday.results.sunrise.formatStringToDate()
        astronomicalTwilightBegin = dataToday.results.astronomical_twilight_begin.formatStringToDate()
        
        ATInterval = DateInterval(start: dataToday.results.astronomical_twilight_end.formatStringToDate(), end: dataTomorrow.results.astronomical_twilight_begin.formatStringToDate())
        nightInterval = DateInterval(start: dataToday.results.sunset.formatStringToDate(), end: dataTomorrow.results.sunrise.formatStringToDate())
    }
    
    init(astronomicalTwilightBegin: Date, sunrise: Date, ATInterval: DateInterval, nightInterval: DateInterval) {
        self.astronomicalTwilightBegin = astronomicalTwilightBegin
        self.sunrise = sunrise
        self.ATInterval = ATInterval
        self.nightInterval = nightInterval
    }
    
    init(sunEventsToday: SunEvents, sunEventsTomorrow: SunEvents) {
        astronomicalTwilightBegin = sunEventsToday.astronomicalDawn!
        sunrise = sunEventsToday.sunrise!
        ATInterval = DateInterval(start: sunEventsToday.astronomicalDusk!, end: sunEventsTomorrow.astronomicalDawn!)
        nightInterval = DateInterval(start: sunEventsToday.sunset!, end: sunEventsTomorrow.sunrise!)
    }
}

extension SunData {
    static var dummy: SunData {
        SunData(astronomicalTwilightBegin: Date().startOfDay().addingTimeInterval(21000), sunrise: Date().startOfDay().addingTimeInterval(21600), ATInterval: DateInterval(start: Date().startOfDay().addingTimeInterval(68500), duration: 43200), nightInterval: DateInterval(start: Date().startOfDay().addingTimeInterval(70000), duration: 43200))
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
