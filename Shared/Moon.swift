//
//  Moon.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/23/22.
//

import Foundation

struct Moon {
    static func getMoonIllumination(date: Date, timezone: TimeZone) -> Double {
        let date = date.endOfLocalDay(timezone: timezone)
        func getMoonAge(date: Date) -> Double {
            // lunar cycle length in seconds
            let cycle = 29.53058770576 * 24 * 60 * 60
            // new moon reference date
            let new2000 = 947182440.0
            let totalSecs = date.timeIntervalSince1970 - new2000
            let age = totalSecs.mod(by: cycle)
            return age / 60 / 60 / 24
        }
        
        return pow(sin(getMoonAge(date: date)/29.86 * Double.pi),2)
    }
    

//    static func getAltitude(location: Location, time: Date) -> Double {
//        // Calculate the number of days since the J2000 epoch
//        let d = Date.daysSinceJ2000(until: time)
//
//        // Constants for the mean longitude and mean anomaly of the celestial object
//        let meanLongitude = (218.316 + 481267.881 * d).mod(by: 360)
//        let meanAnomaly = (134.963 + 477198.867 * d).mod(by: 360)
//
//        // Calculate the celestial object's apparent longitude
//        let lambda = meanLongitude + 1.915 * sin(meanAnomaly.toRadian()) + 0.02 * sin(2 * meanAnomaly.toRadian())
//
//        // Calculate the obliquity of the ecliptic (epsilon)
//        let epsilon = 23.439 - 0.0000004 * d
//
//        // Calculate X and Y coordinates
//        let Y = cos(epsilon.toRadian()) * sin(lambda.toRadian())
//        let X = cos(lambda.toRadian())
//
//        // Calculate the celestial object's right ascension (RA)
//        let ra: Double = {
//            if X < 0 {
//                return atan(Y/X).toDegree() + 180
//            } else if Y < 0 && X > 0 {
//                return atan(Y/X).toDegree() + 360
//            } else {
//                return atan(Y/X).toDegree()
//            }
//        }()
//
//        // Calculate the celestial object's declination (Dec)
//        let dec = asin(sin(epsilon.toRadian()) * sin(lambda.toRadian())).toDegree()
//
//        let lst = 100.46 + (0.985647 * d) + location.longitude + (15 * time.dateToUTCHours(location: location)).mod(by: 360)
//        let ha = (lst - ra).mod(by: 360)
//        let sinAlt = sin(dec.toRadian()) * sin(location.latitude.toRadian()) + cos(dec.toRadian()) * cos(location.latitude.toRadian()) * cos(ha.toRadian())
//        return asin(sinAlt).toDegree()
//    }
}

