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
}

