//
//  Sun.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 7/12/23.
//

import Foundation

struct Sun {
    
    static var sol = Sun()
    
    private init() {}
    
    func getAltitude(location: Location, time: Date) -> Double {
        let d = Date.daysSinceJ2000(until: time)
        
        let meanLongitude = (280.461 + 0.985647 * d).mod(by: 360)
        let meanAnomoly = (357.528 + 0.985647 * d).mod(by: 360)
        
        let lambda = meanLongitude + 1.915 * sin(meanAnomoly.toRadian()) + 0.02 * sin(2 * meanAnomoly.toRadian())
        let epsilon = 23.439 - 0.0000004 * d
        
        let Y = cos(epsilon.toRadian()) * sin(lambda.toRadian())
        let X = cos(lambda.toRadian())
        
        let a = atan(Y/X).toDegree()
        
        let ra = {
            if X < 0 {
                return a + 180
            } else if Y < 0 && X > 0 {
                return a + 360
            } else {
                return a
            }
        }()
        
        let dec = asin(sin(epsilon.toRadian())*sin(lambda.toRadian())).toDegree()
        
        let lst = 100.46 + (0.985647 * d) + location.longitude + (15 * time.dateToUTCHours(location: location)).mod(by: 360)
        let ha = (lst - ra).mod(by: 360)
        let sinAlt = sin(dec.toRadian()) * sin(location.latitude.toRadian()) + cos(dec.toRadian()) * cos(location.latitude.toRadian()) * cos(ha.toRadian())
        return asin(sinAlt).toDegree()
    }
    
    private func binaryAltitudeSearch(startTime: Date, initialIncrement: TimeInterval, finalIncrement: TimeInterval, condition: (Date, TimeInterval) -> Bool) -> Date {
        var start = startTime
        var increment = initialIncrement
        
        while increment > finalIncrement {
            if condition(start, increment) {
                start.addTimeInterval(increment)
            } else {
                increment /= 2
            }
        }
        
        return start
    }
    
    func getCulmination(location: Location, date: Date) -> Date {
        // modified start time to 12AM
        let time = binaryAltitudeSearch(startTime: date.startOfLocalDay(timezone: location.timezone), initialIncrement: 21_600, finalIncrement: 60) { time, increment in
            slope(location: location, time: time) > 0 || slope(location: location, time: time.addingTimeInterval(increment)) < 0
        }
        
        return time
        
        /**
         - Returns: An approximate IROC for altitude vs time at the given time in degrees per second
         */
        func slope(location: Location, time: Date) -> Double {
            let alt1 = getAltitude(location: location, time: time)
            let alt2 = getAltitude(location: location, time: time.addingTimeInterval(1))
           return alt1 - alt2
        }
    }
    
    func getNextInterval(location: Location, date: Date) -> SunData {
        
        let culmination = getCulmination(location: location, date: date)
        let antiCulmination = culmination.addingTimeInterval(43_080)
        
        let culminationAltitude = getAltitude(location: location, time: culmination)
        let antiCulminationAltitude = getAltitude(location: location, time: antiCulmination)
        
        var events = SunData.SunEvents(solarNoon: culmination, solarMidnight: antiCulmination)
        
        // astro dusk occurs if the sun is above -18 degrees and goes below -18 degrees
        if culminationAltitude >= -18 && antiCulminationAltitude <= -18 {
            // search for the next astro twilight time after the culmination
            events.astronomicalDusk = binaryAltitudeSearch(startTime: culmination, initialIncrement: 21_600, finalIncrement: 60) { time, increment in
                getAltitude(location: location, time: time) < -18 || getAltitude(location: location, time: time.addingTimeInterval(increment)) > -18
            }
            // search for the next astro twilight after the anti-culmination
            events.astronomicalDawn = binaryAltitudeSearch(startTime: antiCulmination, initialIncrement: 21_600, finalIncrement: 60) { time, increment in
                getAltitude(location: location, time: time) > -18 || getAltitude(location: location, time: time.addingTimeInterval(increment)) < -18
            }
        }
        
        // nautical dusk occurs if the sun is above -12 degrees goes below -12 degrees
        if culminationAltitude >= -12 && antiCulminationAltitude <= -12 {
            // search for the next set time after the culmination
            events.nauticalDusk = binaryAltitudeSearch(startTime: culmination, initialIncrement: 21_600, finalIncrement: 60) { time, increment in
                getAltitude(location: location, time: time) < -12 || getAltitude(location: location, time: time.addingTimeInterval(increment)) > -12
            }
            
            // search for the next rise time after the anti-culmination
            events.nauticalDawn = binaryAltitudeSearch(startTime: antiCulmination, initialIncrement: 21_600, finalIncrement: 60) { time, increment in
                getAltitude(location: location, time: time) > -12 || getAltitude(location: location, time: time.addingTimeInterval(increment)) < -12
            }
        }
        
        // civil dusk occurs if the sun is above -6 degrees and goes below -6 degrees
        if culminationAltitude >= -6 && antiCulminationAltitude <= -6 {
            // search for the next set time after the culmination
            events.civilDusk = binaryAltitudeSearch(startTime: culmination, initialIncrement: 21_600, finalIncrement: 60) { time, increment in
                getAltitude(location: location, time: time) < -6 || getAltitude(location: location, time: time.addingTimeInterval(increment)) > -6
            }
            
            // search for the next rise time after the anti-culmination
            events.civilDawn = binaryAltitudeSearch(startTime: antiCulmination, initialIncrement: 21_600, finalIncrement: 60) { time, increment in
                getAltitude(location: location, time: time) > -6 || getAltitude(location: location, time: time.addingTimeInterval(increment)) < -6
            }
        }
        
        // sunset occurs if the sun is above 0 degrees and goes below 0 degrees
        if culminationAltitude >= 0 && antiCulminationAltitude <= 0  {
            // search for the next set time after the culmination
            events.sunset = binaryAltitudeSearch(startTime: culmination, initialIncrement: 21_600, finalIncrement: 60) { time, increment in
                getAltitude(location: location, time: time) < 0 || getAltitude(location: location, time: time.addingTimeInterval(increment)) > 0
            }
            
            // search for the next rise time after the anti-culmination
            events.sunrise = binaryAltitudeSearch(startTime: antiCulmination, initialIncrement: 21_600, finalIncrement: 60) { time, increment in
                getAltitude(location: location, time: time) > 0 || getAltitude(location: location, time: time.addingTimeInterval(increment)) < 0
            }
        }
        return SunData(events: events, location: location)
    }
}

struct SunData: Equatable {
    
    struct SunEvents {
        var sunrise: Date?
        var sunset: Date?
        var civilDusk: Date?
        var civilDawn: Date?
        var nauticalDusk: Date?
        var nauticalDawn: Date?
        var astronomicalDusk: Date?
        var astronomicalDawn: Date?
        let solarNoon: Date
        let solarMidnight: Date
        
        init(sunrise: Date? = nil, sunset: Date? = nil, civilDusk: Date? = nil, civilDawn: Date? = nil, nauticalDusk: Date? = nil, nauticalDawn: Date? = nil, astronomicalDusk: Date? = nil, astronomicalDawn: Date? = nil, solarNoon: Date, solarMidnight: Date) {
            self.sunrise = sunrise
            self.sunset = sunset
            self.civilDusk = civilDusk
            self.civilDawn = civilDawn
            self.nauticalDusk = nauticalDusk
            self.nauticalDawn = nauticalDawn
            self.astronomicalDusk = astronomicalDusk
            self.astronomicalDawn = astronomicalDawn
            self.solarNoon = solarNoon
            self.solarMidnight = solarMidnight
        }
    }
    
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
    
    init(events: SunEvents, location: Location) {
        if let sunset = events.sunset, let sunrise = events.sunrise {
            nightInterval = DateInterval(start: sunset, end: sunrise)
        } else {
            if Sun.sol.getAltitude(location: location, time: events.solarMidnight) > 0 {
                nightInterval = DateInterval(start: events.solarNoon, duration: 0)
            } else {
                nightInterval = DateInterval(start: events.solarNoon, end: events.solarNoon)
            }
        }
        
        if let civilDusk = events.civilDusk, let civilDawn = events.civilDawn {
            CTInterval = DateInterval(start: civilDusk, end: civilDawn)
        } else {
            if Sun.sol.getAltitude(location: location, time: events.solarMidnight) > 0 {
                CTInterval = DateInterval(start: events.solarNoon, duration: 0)
            } else {
                CTInterval = DateInterval(start: events.solarNoon, end: events.solarNoon)
            }
        }
        
        if let nauticalDusk = events.nauticalDusk, let nauticalDawn = events.nauticalDawn {
            NTInterval = DateInterval(start: nauticalDusk, end: nauticalDawn)
        } else {
            if Sun.sol.getAltitude(location: location, time: events.solarMidnight) > 0 {
                NTInterval = DateInterval(start: events.solarNoon, duration: 0)
            } else {
                NTInterval = DateInterval(start: events.solarNoon, end: events.solarNoon)
            }
        }
        
        if let astronomicalDusk = events.astronomicalDusk, let astronomicalDawn = events.astronomicalDawn {
            ATInterval = DateInterval(start: astronomicalDusk, end: astronomicalDawn)
        } else {
            if Sun.sol.getAltitude(location: location, time: events.solarMidnight) > 0 {
                ATInterval = DateInterval(start: events.solarNoon, duration: 0)
            } else {
                ATInterval = DateInterval(start: events.solarNoon, end: events.solarNoon)
            }
        }
        
        solarMidnight = events.solarMidnight
    }
}

