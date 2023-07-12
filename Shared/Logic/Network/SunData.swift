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
    
    init(dataToday: RawSunData, dataTomorrow: RawSunData, location: Location) {
        let solarMidnightTomorrow = dataTomorrow.results.solar_noon.addingTimeInterval(43_200)
        
        if dataToday.results.astronomical_twilight_end != Date(timeIntervalSince1970: 0) && dataTomorrow.results.astronomical_twilight_begin != Date(timeIntervalSince1970: 0) {
            ATInterval = DateInterval(start: dataToday.results.astronomical_twilight_end, end: dataTomorrow.results.astronomical_twilight_begin)
        } else {
            if Sun.getAltitude(location: location, time: solarMidnightTomorrow) > 0 {
                ATInterval = DateInterval(start: dataToday.results.solar_noon, duration: 0)
            } else {
                ATInterval = DateInterval(start: dataToday.results.solar_noon, end: dataTomorrow.results.solar_noon)
            }
        }
        
        if dataToday.results.sunset != Date(timeIntervalSince1970: 0) && dataTomorrow.results.sunrise != Date(timeIntervalSince1970: 0) {
            nightInterval = DateInterval(start: dataToday.results.sunset, end: dataTomorrow.results.sunrise)
        } else {
            if Sun.getAltitude(location: location, time: solarMidnightTomorrow) > 0 {
                nightInterval = DateInterval(start: dataToday.results.solar_noon, duration: 0)
            } else {
                nightInterval = DateInterval(start: dataToday.results.solar_noon, end: dataTomorrow.results.solar_noon)
            }
        }
        
        solarMidnight = dataToday.results.solar_noon.addingTimeInterval(43_200)
    }
    
    init(sunEventsToday: SunEvents, sunEventsTomorrow: SunEvents, location: Location) {
        if let duskToday = sunEventsToday.astronomicalDusk, let dawnTomorrow = sunEventsTomorrow.astronomicalDawn {
            ATInterval = DateInterval(start: duskToday, end: dawnTomorrow)
        } else {
            if Sun.getAltitude(location: location, time: sunEventsTomorrow.solarMidnight!) > 0 {
                ATInterval = DateInterval(start: sunEventsToday.solarNoon!, duration: 0)
            } else {
                ATInterval = DateInterval(start: sunEventsToday.solarNoon!, end: sunEventsTomorrow.solarNoon!)
            }
        }
        
        if let sunsetToday = sunEventsToday.sunset, let sunriseTomorrow = sunEventsTomorrow.sunrise {
            nightInterval = DateInterval(start: sunsetToday, end: sunriseTomorrow)
        } else {
            if Sun.getAltitude(location: location, time: sunEventsTomorrow.solarMidnight!) > 0 {
                nightInterval = DateInterval(start: sunEventsToday.solarNoon!, duration: 0)
            } else {
                nightInterval = DateInterval(start: sunEventsToday.solarNoon!, end: sunEventsTomorrow.solarNoon!)
            }
        }
        
        solarMidnight = sunEventsTomorrow.solarMidnight!
    }
}

struct RawSunData: Decodable {
    let results: Results
    
    struct Results: Decodable {
        let sunrise: Date
        let sunset: Date
        let astronomical_twilight_begin: Date
        let astronomical_twilight_end: Date
        let solar_noon: Date
    }
}
