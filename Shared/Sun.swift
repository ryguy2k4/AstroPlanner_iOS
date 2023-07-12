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
}
