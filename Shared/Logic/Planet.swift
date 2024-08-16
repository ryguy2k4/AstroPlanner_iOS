//
//  Planet.swift
//  DeepSkyCatalog 
//
//  Created by Ryan Sponzilli on 7/14/24.
//

import Foundation

struct Planet {
    
    static let mercury = Planet(i: 7.00487, o: 48.33167, p: 77.45645, a: 0.38709893, n: 4.1520186907, e: 0.20564, l: 252.25084)
    static let venus = Planet(i: 3.39471, o: 76.68069, p: 131.53298, a: 0.72333199, n: 1.625494886, e: 0.00678, l: 181.97973)
    static let mars = Planet(i: 1.85061, o: 49.57854, p: 336.04084, a: 1.52366231, n: 0.5316751873, e: 0.09341233, l: 355.45332)
    static let jupiter = Planet(i: 1.3053, o: 100.55615, p: 14.75385, a: 5.20336301, n: 0.08429844516, e: 0.0484, l: 4.40438)
    static let saturn = Planet(i: 2.48446, o: 113.71504, p: 92.43194, a: 9.53707032, n: 0.03395874244, e: 0.0539, l: 49.94432)
    static let neptune = Planet(i: 1.76917, o: 131.72169, p: 44.97135, a: 30.06896348, n: 0.006068280781, e: 0.00859, l: 304.88003)
    static let uranus = Planet(i: 0.76986, o: 74.22988, p: 170.96424, a: 19.19126393, n: 0.01190237491, e: 0.04726, l: 313.23218)
    
    private init(i: Double, o: Double, p: Double, a: Double, n: Double, e: Double, l: Double) {
        self.i = i
        self.o = o
        self.p = p
        self.a = a
        self.n = n
        self.e = e
        self.l = l
    }
    
    
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
        let v = M + 180/Double.pi * (2 * e - pow(e, 3)/4.0) * sin(M.toRadian()) + (5/4.0 * pow(e, 2) * sin(2*M.toRadian())) + (13/12.0 * pow(e, 3) * sin(3*M.toRadian()))
        
        // Step 3: Radius Vector
        let r = a * (1 - pow(e, 2)) / (1 + e * cos(v.toRadian()))
        
        // Step 4: Heliocentric Coordinates of the Planet
        let X = r * (cos(o.toRadian()) * cos((v + p - o).toRadian()) - sin(o.toRadian()) * sin((v + p - o).toRadian()) * cos(i.toRadian()))
        let Y = r * (sin(o.toRadian()) * cos((v + p - o).toRadian()) + cos(o.toRadian()) * sin((v + p - o).toRadian()) * cos(i.toRadian()))
        let Z = r * (sin((v + p - o).toRadian()) * sin(i.toRadian()))
        
        // Step 5: Heliocentric Coordinates of the Earth
        let ee = 0.01671022
        let Me = (0.9855796 * d + 328.40353 - 102.94719).mod(by: 360)
        let ve = Me + 180/Double.pi * (2 * ee - pow(ee, 3)/4.0) * sin(Me.toRadian()) + (5/4.0 * pow(ee, 2) * sin(2*Me.toRadian())) + (13/12.0 * pow(ee, 3) * sin(3*Me.toRadian()))
        let re = 1.0000200 * (1 - pow(ee, 2)) / (1 + ee * cos(ve.toRadian()))
        
        let Xe = re * cos((ve + 102.8517).toRadian())
        let Ye = re * sin((ve + 102.8517).toRadian())
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


import Foundation

//class Planet {
//    var ip: Double
//    var op: Double
//    var pp: Double
//    var ap: Double
//    var ep: Double
//    var lp: Double
//    
//    init(ip: Double, op: Double, pp: Double, ap: Double, ep: Double, lp: Double) {
//        self.ip = ip
//        self.op = op
//        self.pp = pp
//        self.ap = ap
//        self.ep = ep
//        self.lp = lp
//    }
//    
//    static let d = Date.daysSinceJ2000()
//    
//    
//    static let mars = Planet(ip: 1.85061 * .pi / 180, op: 49.57854 * .pi / 180, pp: 336.04084 * .pi / 180, ap: 1.52366231, ep: 0.09341233, lp: 355.45332 * .pi / 180)
//
//    
//    static func FNkep(m: Double, ecc: Double, eps: Int) -> Double {
//        var e = m
//        var delta: Double
//        repeat {
//            delta = e - ecc * sin(e) - m
//            e = e - delta / (1 - ecc * cos(e))
//        } while abs(delta) >= pow(10, -Double(eps))
//        var v = 2 * atan(sqrt((1 + ecc) / (1 - ecc)) * tan(0.5 * e))
//        if v < 0 {
//            v += 2 * .pi
//        }
//        return v
//    }
//    
//    static func FNdegmin(_ x: Double) -> Double {
//        let a = floor(x)
//        let b = x - a
//        let e = floor(60 * b)
//        return a + e / 100
//    }
//    
//    func calculatePosition(location: Location, date: Date) -> Double {
//        let degs = 180.0 / .pi
//        
//        // Earth elements
//        let ie = (0.00005 - 0.000000356985 * Planet.d) * .pi / 180
//        let oe = (-11.26064 - 0.00013863 * Planet.d) * .pi / 180
//        let pe = (102.94719 + 0.00000911309 * Planet.d) * .pi / 180
//        let ae = 1.00000011 - 1.36893e-12 * Planet.d
//        let ee = 0.01671022 - 0.00000000104148 * Planet.d
//        let le = (100.46435 + 0.985609101 * Planet.d).mod(by: 2 * .pi)
//        
//        // Position of Earth in orbit
//        let me = (le - pe).mod(by: 2 * .pi)
//        let ve = Planet.FNkep(m: me, ecc: ee, eps: 12)
//        let re = ae * (1 - ee * ee) / (1 + ee * cos(ve))
//        let xe = re * cos(ve + pe)
//        let ye = re * sin(ve + pe)
//        let ze = 0.0
//        
//        // Position of planet in its orbit
//        let mp = (lp - pp).mod(by: 2 * .pi)
//        let vp = Planet.FNkep(m: mp, ecc: ep, eps: 12)
//        let rp = ap * (1 - ep * ep) / (1 + ep * cos(vp))
//        
//        // Heliocentric rectangular coordinates of planet
//        let xh = rp * (cos(op) * cos(vp + pp - op) - sin(op) * sin(vp + pp - op) * cos(ip))
//        let yh = rp * (sin(op) * cos(vp + pp - op) + cos(op) * sin(vp + pp - op) * cos(ip))
//        let zh = rp * (sin(vp + pp - op) * sin(ip))
//        
//        // Convert to geocentric rectangular coordinates
//        let xg = xh - xe
//        let yg = yh - ye
//        let zg = zh
//        
//        // Step 7: Equatorial Coordinates of the Planet
//        let ec = 23.439292.toRadian()
//        let Xq = xg
//        let Yq = yg * cos(ec) - zg * sin(ec)
//        let Zq = yg * sin(ec) + zg * cos(ec)
//
//        let a = atan(Yq/Xq).toDegree()
//
//        let ra = {
//            if Xq < 0 {
//                return a + 180
//            } else if Yq < 0 && Xq > 0 {
//                return a + 360
//            } else {
//                return a
//            }
//        }()
//        print("ra: \(ra/15.0) hrs")
//
//        let dec = atan( Zq.toRadian() / sqrt(pow(Xq.toRadian(), 2) + pow(Yq.toRadian(), 2))).toDegree()
//        print("dec: \(dec) deg")
//
//        // Step 7: Convert Ra/Dec to Alt/Az
//        let lst = 100.46 + (0.985647 * Planet.d) + location.longitude + (15 * date.dateToUTCHours(location: location)).mod(by: 360)
//        let ha = (lst - ra).mod(by: 360)
//        let sinAlt = sin(dec.toRadian()) * sin(location.latitude.toRadian()) + cos(dec.toRadian()) * cos(location.latitude.toRadian()) * cos(ha.toRadian())
//        return asin(sinAlt).toDegree()
//    }
//}
