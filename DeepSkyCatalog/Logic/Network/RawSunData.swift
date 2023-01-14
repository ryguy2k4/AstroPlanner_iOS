//
//  SunData.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/11/22.
//

import Foundation

struct RawSunData: Decodable {
    let results: Results
    
    struct Results: Decodable {
        let sunrise: String
        let sunset: String
        let astronomical_twilight_begin: String
        let astronomical_twilight_end: String
    }
}

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
}

extension SunData {
    static let dummy: SunData = SunData()

    private init() {
        self.astronomicalTwilightBegin = Date.today
        self.sunrise = Date.today
        self.ATInterval = DateInterval(start: Date.today, end: Date.tomorrow)
        self.nightInterval = DateInterval(start: Date.today, end: Date.tomorrow)
    }
}
