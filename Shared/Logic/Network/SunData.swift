//
//  SunData.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/11/22.
//

import Foundation
import WeatherKit

struct SunData: Equatable {
    
    /// An Interval from Sunset on the current night to sunrise on the following morning
    let nightInterval: DateInterval
    
    /// An Interval from Civil Dusk on the current night to Civil Dawn on the following morning
    let CTInterval: DateInterval
    
    /// An Interval from Nautical Dusk on the current night to Nautical Dawn on the following morning
    let NTInterval: DateInterval
    
    /// An Interval from Astronomical Dusk on the current night to Astronomical Dawn on the following morning
    let ATInterval: DateInterval
    
    let solarMidnight: Date
    
    static let `default`: SunData = .init()
    
    init() {
        self.ATInterval = .init(start: .now, duration: .pi)
        self.CTInterval = .init(start: .now, duration: .pi)
        self.NTInterval = .init(start: .now, duration: .pi)
        self.nightInterval = .init(start: .now, duration: .pi)
        self.solarMidnight = .now
    }
    
    init(astronomicalTwilightBegin: Date, astronomicalTwilightEnd: Date, nauticalTwilightBegin: Date, nauticalTwilightEnd: Date, civilTwilightBegin: Date, civilTwilightEnd: Date, sunset: Date, sunrise: Date, solarMidnight: Date) {
        self.ATInterval = .init(start: astronomicalTwilightBegin, end: astronomicalTwilightEnd)
        self.CTInterval = .init(start: nauticalTwilightBegin, end: nauticalTwilightEnd)
        self.NTInterval = .init(start: civilTwilightBegin, end: civilTwilightEnd)
        self.nightInterval = .init(start: sunset, end: sunrise)
        self.solarMidnight = solarMidnight
    }
    
    init(dataToday: RawSunData, dataTomorrow: RawSunData, location: Location) {
        let solarMidnightTomorrow = dataTomorrow.results.solar_noon.addingTimeInterval(43_200)
        
        if dataToday.results.sunset != Date(timeIntervalSince1970: 0) && dataTomorrow.results.sunrise != Date(timeIntervalSince1970: 0) {
            nightInterval = DateInterval(start: dataToday.results.sunset, end: dataTomorrow.results.sunrise)
        } else {
            if Sun.getAltitude(location: location, time: solarMidnightTomorrow) > 0 {
                nightInterval = DateInterval(start: dataToday.results.solar_noon, duration: 0)
            } else {
                nightInterval = DateInterval(start: dataToday.results.solar_noon, end: dataTomorrow.results.solar_noon)
            }
        }
        
        if dataToday.results.civil_twilight_end != Date(timeIntervalSince1970: 0) && dataTomorrow.results.civil_twilight_begin != Date(timeIntervalSince1970: 0) {
            CTInterval = DateInterval(start: dataToday.results.civil_twilight_end, end: dataTomorrow.results.civil_twilight_begin)
        } else {
            if Sun.getAltitude(location: location, time: solarMidnightTomorrow) > 0 {
                CTInterval = DateInterval(start: dataToday.results.solar_noon, duration: 0)
            } else {
                CTInterval = DateInterval(start: dataToday.results.solar_noon, end: dataTomorrow.results.solar_noon)
            }
        }
        
        if dataToday.results.nautical_twilight_end != Date(timeIntervalSince1970: 0) && dataTomorrow.results.nautical_twilight_begin != Date(timeIntervalSince1970: 0) {
            NTInterval = DateInterval(start: dataToday.results.nautical_twilight_end, end: dataTomorrow.results.nautical_twilight_begin)
        } else {
            if Sun.getAltitude(location: location, time: solarMidnightTomorrow) > 0 {
                NTInterval = DateInterval(start: dataToday.results.solar_noon, duration: 0)
            } else {
                NTInterval = DateInterval(start: dataToday.results.solar_noon, end: dataTomorrow.results.solar_noon)
            }
        }
        
        if dataToday.results.astronomical_twilight_end != Date(timeIntervalSince1970: 0) && dataTomorrow.results.astronomical_twilight_begin != Date(timeIntervalSince1970: 0) {
            ATInterval = DateInterval(start: dataToday.results.astronomical_twilight_end, end: dataTomorrow.results.astronomical_twilight_begin)
        } else {
            if Sun.getAltitude(location: location, time: solarMidnightTomorrow) > 0 {
                ATInterval = DateInterval(start: dataToday.results.solar_noon, duration: 0)
            } else {
                ATInterval = DateInterval(start: dataToday.results.solar_noon, end: dataTomorrow.results.solar_noon)
            }
        }
        
        solarMidnight = dataToday.results.solar_noon.addingTimeInterval(43_200)
    }
    
    init(sunEventsToday: SunEvents, sunEventsTomorrow: SunEvents, location: Location) {
        if let sunsetToday = sunEventsToday.sunset, let sunriseTomorrow = sunEventsTomorrow.sunrise {
            nightInterval = DateInterval(start: sunsetToday, end: sunriseTomorrow)
        } else {
            if Sun.getAltitude(location: location, time: sunEventsTomorrow.solarMidnight!) > 0 {
                nightInterval = DateInterval(start: sunEventsToday.solarNoon!, duration: 0)
            } else {
                nightInterval = DateInterval(start: sunEventsToday.solarNoon!, end: sunEventsTomorrow.solarNoon!)
            }
        }
        
        if let civilDuskToday = sunEventsToday.civilDusk, let civilDawnTomorrow = sunEventsTomorrow.civilDawn {
            CTInterval = DateInterval(start: civilDuskToday, end: civilDawnTomorrow)
        } else {
            if Sun.getAltitude(location: location, time: sunEventsTomorrow.solarMidnight!) > 0 {
                CTInterval = DateInterval(start: sunEventsToday.solarNoon!, duration: 0)
            } else {
                CTInterval = DateInterval(start: sunEventsToday.solarNoon!, end: sunEventsTomorrow.solarNoon!)
            }
        }
        
        if let nauticalDuskToday = sunEventsToday.nauticalDusk, let nauticalDawnTomorrow = sunEventsTomorrow.nauticalDawn {
            NTInterval = DateInterval(start: nauticalDuskToday, end: nauticalDawnTomorrow)
        } else {
            if Sun.getAltitude(location: location, time: sunEventsTomorrow.solarMidnight!) > 0 {
                NTInterval = DateInterval(start: sunEventsToday.solarNoon!, duration: 0)
            } else {
                NTInterval = DateInterval(start: sunEventsToday.solarNoon!, end: sunEventsTomorrow.solarNoon!)
            }
        }
        
        if let astroDuskToday = sunEventsToday.astronomicalDusk, let astroDawnTomorrow = sunEventsTomorrow.astronomicalDawn {
            ATInterval = DateInterval(start: astroDuskToday, end: astroDawnTomorrow)
        } else {
            if Sun.getAltitude(location: location, time: sunEventsTomorrow.solarMidnight!) > 0 {
                ATInterval = DateInterval(start: sunEventsToday.solarNoon!, duration: 0)
            } else {
                ATInterval = DateInterval(start: sunEventsToday.solarNoon!, end: sunEventsTomorrow.solarNoon!)
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
        let civil_twilight_begin: Date
        let civil_twilight_end: Date
        let nautical_twilight_begin: Date
        let nautical_twilight_end: Date
        let astronomical_twilight_begin: Date
        let astronomical_twilight_end: Date
        let solar_noon: Date
    }
}
