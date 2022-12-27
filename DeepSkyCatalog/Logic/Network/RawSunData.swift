//
//  SunData.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/11/22.
//

import Foundation

struct SunData {
    
    let astronomicalTwilightBegin: Date
    let nauticalTwilightBegin: Date
    let civilTwilightBegin: Date
    let sunrise: Date
    let solarNoon: Date
    
    let ATInterval: DateInterval
    let NTInterval: DateInterval
    let CTInterval: DateInterval
    let nightInterval: DateInterval
    
    init(from dataToday: RawSunData, and dataTomorrow: RawSunData) {
        sunrise = dataToday.results.sunrise.formatStringToDate()
        solarNoon = dataToday.results.solar_noon.formatStringToDate()
        civilTwilightBegin = dataToday.results.civil_twilight_begin.formatStringToDate()
        nauticalTwilightBegin = dataToday.results.nautical_twilight_begin.formatStringToDate()
        astronomicalTwilightBegin = dataToday.results.astronomical_twilight_begin.formatStringToDate()
        
        ATInterval = DateInterval(start: dataToday.results.astronomical_twilight_end.formatStringToDate(), end: dataTomorrow.results.astronomical_twilight_begin.formatStringToDate())
        NTInterval = DateInterval(start: dataToday.results.nautical_twilight_end.formatStringToDate(), end: dataTomorrow.results.nautical_twilight_begin.formatStringToDate())
        CTInterval = DateInterval(start: dataToday.results.civil_twilight_end.formatStringToDate(), end: dataTomorrow.results.civil_twilight_begin.formatStringToDate())
        nightInterval = DateInterval(start: dataToday.results.sunset.formatStringToDate(), end: dataTomorrow.results.sunrise.formatStringToDate())
    }
}

struct RawSunData: Decodable {
    let results: Results
    
    struct Results: Decodable {
        let sunrise: String
        let sunset: String
        let solar_noon: String
        let civil_twilight_begin: String
        let civil_twilight_end: String
        let nautical_twilight_begin: String
        let nautical_twilight_end: String
        let astronomical_twilight_begin: String
        let astronomical_twilight_end: String
    }
}
