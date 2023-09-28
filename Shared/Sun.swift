//
//  Sun.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 7/12/23.
//

import Foundation

struct Sun {
    static func getAltitude(location: Location, time: Date) -> Double {
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
    
    private static func binaryAltitudeSearch(startTime: Date, initialIncrement: TimeInterval, finalIncrement: TimeInterval, condition: (Date, TimeInterval) -> Bool) -> Date {
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
    
    static func getCulmination(location: Location, date: Date) -> Date {
        // modified start time to 12AM
        let time = binaryAltitudeSearch(startTime: date.startOfLocalDay(timezone: location.timezone), initialIncrement: 21_600, finalIncrement: 60) { time, increment in
            slope(location: location, time: time) > 0 || slope(location: location, time: time.addingTimeInterval(increment)) < 0
        }
        
        return time
        
        /**
         - Returns: An approximate IROC for altitude vs time at the given time in degrees per second
         */
        func slope(location: Location, time: Date) -> Double {
            let alt1 = Sun.getAltitude(location: location, time: time)
            let alt2 = Sun.getAltitude(location: location, time: time.addingTimeInterval(1))
           return alt1 - alt2
        }
    }
    
    static func getNextInterval(location: Location, date: Date) -> SunData {
        
        let culmination = Sun.getCulmination(location: location, date: date)
        let antiCulmination = culmination.addingTimeInterval(43_080)
        
        let culminationAltitude = getAltitude(location: location, time: culmination)
        let antiCulminationAltitude = getAltitude(location: location, time: antiCulmination)
        
        var astronomicalTwilightBegin: Date? = nil
        var astronomicalTwilightEnd: Date? = nil
        var nauticalTwilightEnd: Date? = nil
        var nauticalTwilightBegin: Date? = nil
        var civilTwilightEnd: Date? = nil
        var civilTwilightBegin: Date? = nil
        var sunrise: Date? = nil
        var sunset: Date? = nil
        
        if antiCulminationAltitude < -18 {
            print("No Astronomical Twilight")
        } 
        
        if antiCulminationAltitude >= -18 {
            print("No Nautical Twilight")
            // search for the next astro twilight time after the culmination
            astronomicalTwilightBegin = Sun.binaryAltitudeSearch(startTime: culmination, initialIncrement: 21_600, finalIncrement: 60) { time, increment in
                Sun.getAltitude(location: location, time: time) < -18 || Sun.getAltitude(location: location, time: time.addingTimeInterval(increment)) > -18
            }
            // search for the next astro twilight after the anti-culmination
            astronomicalTwilightEnd = Sun.binaryAltitudeSearch(startTime: antiCulmination, initialIncrement: 21_600, finalIncrement: 60) { time, increment in
                Sun.getAltitude(location: location, time: time) > -18 || Sun.getAltitude(location: location, time: time.addingTimeInterval(increment)) < -18
            }
        }
        
        if antiCulminationAltitude >= -12 {
            print("No Civil Twilight")
            // search for the next set time after the culmination
            nauticalTwilightBegin = Sun.binaryAltitudeSearch(startTime: culmination, initialIncrement: 21_600, finalIncrement: 60) { time, increment in
                Sun.getAltitude(location: location, time: time) < -12 || Sun.getAltitude(location: location, time: time.addingTimeInterval(increment)) > -12
            }
            
            // search for the next rise time after the anti-culmination
            nauticalTwilightEnd = Sun.binaryAltitudeSearch(startTime: antiCulmination, initialIncrement: 21_600, finalIncrement: 60) { time, increment in
                Sun.getAltitude(location: location, time: time) > -12 || Sun.getAltitude(location: location, time: time.addingTimeInterval(increment)) < -12
            }
        }
        
        if antiCulminationAltitude >= -6 {
            print("No Sunrise")
            // search for the next set time after the culmination
            civilTwilightBegin = Sun.binaryAltitudeSearch(startTime: culmination, initialIncrement: 21_600, finalIncrement: 60) { time, increment in
                Sun.getAltitude(location: location, time: time) < -6 || Sun.getAltitude(location: location, time: time.addingTimeInterval(increment)) > -6
            }
            
            // search for the next rise time after the anti-culmination
            civilTwilightEnd = Sun.binaryAltitudeSearch(startTime: antiCulmination, initialIncrement: 21_600, finalIncrement: 60) { time, increment in
                Sun.getAltitude(location: location, time: time) > -6 || Sun.getAltitude(location: location, time: time.addingTimeInterval(increment)) < -6
            }
        }
        
        if antiCulminationAltitude >= 0 {
            print("No Sunrise")
            // search for the next set time after the culmination
            sunset = Sun.binaryAltitudeSearch(startTime: culmination, initialIncrement: 21_600, finalIncrement: 60) { time, increment in
                Sun.getAltitude(location: location, time: time) < 0 || Sun.getAltitude(location: location, time: time.addingTimeInterval(increment)) > 0
            }
            
            // search for the next rise time after the anti-culmination
            sunrise = Sun.binaryAltitudeSearch(startTime: antiCulmination, initialIncrement: 21_600, finalIncrement: 60) { time, increment in
                Sun.getAltitude(location: location, time: time) > 0 || Sun.getAltitude(location: location, time: time.addingTimeInterval(increment)) < 0
            }
        }
        
        return SunData(astronomicalTwilightBegin: astronomicalTwilightBegin, astronomicalTwilightEnd: astronomicalTwilightEnd, nauticalTwilightBegin: nauticalTwilightBegin, nauticalTwilightEnd: nauticalTwilightEnd, civilTwilightBegin: civilTwilightBegin, civilTwilightEnd: civilTwilightEnd, sunset: sunset, sunrise: sunrise, solarMidnight: antiCulmination)
    }
}
