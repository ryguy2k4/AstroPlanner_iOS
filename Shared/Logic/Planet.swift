//
//  Planet.swift
//  DeepSkyCatalog 
//
//  Created by Ryan Sponzilli on 7/14/24.
//

import Foundation

struct Planet {
    
    static let mars = Planet(i: 1.85061, o: 49.57854, p: 336.04084, a: 1.52366231, n: 0.5240613, e: 0.09341233, l: 355.45332)
    
    
    private let i: Double // inclination
    private let o: Double // longitude ascending node
    private let p: Double // longitude perihelion
    private let a: Double // mean distance
    private let n: Double // daily motion
    private let e: Double // eccentricity
    private let l: Double // mean longitude
    
    func getAltitude(location: Location, time: Date) -> Double {
        // Step 1: Days Since J2000
        let d = Date.daysSinceJ2000(until: time)
        
        // Step 2: Mean Anomoly
        let M = (n * d + l - p).mod(by: 360)
        
        // Step 3: True Anomoly
        let v = M + 180/Double.pi * (2 * e - pow(e, 0.75)) * sin(M.toRadian()) + (5/4.0 * pow(e, 2) * sin(2*M.toRadian())) + (13/12.0 * pow(e, 3) * sin(3*M.toRadian()))
        
        // Step 3: Radius Vector
        let r = a * (1 - pow(e, 2)) / (1 + e * cos(v.toRadian()))
        
        // Step 4: Heliocentric Coordinates of the Planet
        let X = r * (cos(o.toRadian()) * cos((v + p - o).toRadian()) - sin(o.toRadian()) * sin((v + p - o).toRadian()) * cos(i.toRadian()))
        let Y = r * (sin(o.toRadian()) * cos((v + p - o).toRadian()) + cos(o.toRadian()) * sin((v + p - o).toRadian()) * cos(i.toRadian()))
        let Z = r * (sin((v + p - o).toRadian()) * sin(i.toRadian()))
        
        // Step 5: Heliocentric Coordinates of the Earth
        let Xe = r * cos((v + p).toRadian())
        let Ye = r * sin((v + p).toRadian())
        let Ze = 0.0
        
        // Step 6: Geocentric Coordinates of the Planet
        let X2 = X - Xe
        let Y2 = Y - Ye
        let Z2 = Z - Ze
        
        
        // Step 7: Equatorial Coordinates of the Planet
        let ec = 23.439292.toRadian()
        let Xq = X2
        let Yq = Y2 * cos(ec) - Z2 * sin(ec)
        let Zq = Y2 * sin(ec) + Z2 * cos(ec)
        
        let a = atan(Yq/Xq).toDegree()
        
        let ra = {
            if Xq < 0 {
                return a + 180
            } else if Yq < 0 && Xq > 0 {
                return a + 360
            } else {
                return a
            }
        }()
        print("ra: \(ra/15.0) hrs")
        
        let dec = atan( Zq.toRadian() / sqrt(pow(Xq.toRadian(), 2) + pow(Yq.toRadian(), 2))).toDegree()
        print("dec: \(dec) deg")
        
        // Step 7: Convert Ra/Dec to Alt/Az
        let lst = 100.46 + (0.985647 * d) + location.longitude + (15 * time.dateToUTCHours(location: location)).mod(by: 360)
        let ha = (lst - ra).mod(by: 360)
        let sinAlt = sin(dec.toRadian()) * sin(location.latitude.toRadian()) + cos(dec.toRadian()) * cos(location.latitude.toRadian()) * cos(ha.toRadian())
        return asin(sinAlt).toDegree()
        
    }
    
}


/*
 Sun
 Mean Longitude
 Mean Anomoly
 Ecliptic Longitude (Lambda)
 Obliquity of the Ecliptic Plane (Epsilon)
 
 
 Planet
 Inclination
 Longitude of Ascending Node
 Longitude of Perihelion
 Mean Distance
 Daily Motion
 Eccentricity
 Mean Longitude
 */
