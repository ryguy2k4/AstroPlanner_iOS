//
//  DeepSkyTarget.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/2/22.
//

import Foundation

/**
 An object that represents a specific deep sky target.
 - Parameter name: The common names of the target.
 - Parameter designation: The official catalog designations of the target.
 - Parameter image: Fllenames for images of the target.
 - Parameter description: A detailed description of the target.
 - Parameter descriptionURL: A Wikipedia link.
 - Parameter type: The type of deep sky object.
 - Parameter constellation: The constellation the target lies in.
 - Parameter ra: The right ascension of the target (J2000).
 - Parameter dec: The declination of the target (J2000).
 - Parameter arcLength: The longer side of the target measured in arcminutes.
 - Parameter arcWidth: The shorter side of the target measured in arcminutes.
 - Parameter apparentMag: The apparent magnitude of the target.
 */

struct DeepSkyTarget: Identifiable, Hashable {
    // identifiers
    let id = UUID()
    let name: [String]
    let designation: [Designation]
    
    // image
    let image: TargetImage
    
    // description
    let description: String
    let descriptionURL: URL
    let type: [DSOType]
    
    // characteristics
    let constellation: Constellation
    let ra: Double
    let dec: Double
    let arcLength: Double
    let arcWidth: Double
    let apparentMag: Double
    
    struct TargetImage: Hashable, Codable {
        enum ImageSource: Hashable, Codable {
            case apod(id: String)
            case local(fileName: String)
            
            var fileName: String {
                switch self {
                case .apod(id: let id):
                    return "apod_" + id
                case .local(fileName: let filename):
                    return filename
                }
            }
        }
        
        let source: ImageSource
        let copyright: String?
    }
    
    /**
     Gets the altitude of the target.
     - Parameter location: The location to calculate the altitude at.
     - Parameter time: The time to calculate the altitude at.
     - Returns: The altitude of the target at the given time and location measured in degrees.
     
     LST = 100.46 + 0.985647 * d + long + 15*UT
     HA = LST - RA
     sin(ALT) = sin(DEC)*sin(LAT)+cos(DEC)*cos(LAT)*cos(HA)
     */
    func getAltitude(location: SavedLocation, time: Date) -> Double {
        let d = Date.daysSinceJ2000(until: time)
        let lst = 100.46 + (0.985647 * d) + location.longitude + (15 * time.dateToUTCHours(location: location)).mod(by: 360)
        let ha = (lst - ra).mod(by: 360)
        let sinAlt = sin(dec.toRadian()) * sin(location.latitude.toRadian()) + cos(dec.toRadian()) * cos(location.latitude.toRadian()) * cos(ha.toRadian())
        return asin(sinAlt).toDegree()
    }
        
    /**
     The local sidereal time (LST) that the target rises above the given altitude.
     LST = HA + RA
     HA = 360 - ( acos ( sin(ALT) * sec(DEC) * sec(LAT) - tan(DEC) * tan(LAT) ) )
     where HA is hour angle and RA is right ascension
     - Parameter location: The location at which sidereal time should be calculated.
     - Parameter alt: The altitude that should be converted to local sidereal time.
     - Returns: The local sidereal times at which the object reaches the given altitude.
     */
    private func getLST(location: SavedLocation, from alt: Double) throws -> [Double] {
        let cosHourAngle = sin(alt.toRadian()) * (1/cos(dec.toRadian())) * (1/cos(location.latitude.toRadian())) - tan(dec.toRadian()) * tan(location.latitude.toRadian())
        if cosHourAngle > 1 {
            throw TargetCalculationError.neverRises
        } else if cosHourAngle < -1 {
            throw TargetCalculationError.neverSets
        }
        let hourAngle = acos(cosHourAngle).toDegree()
        return [360 - hourAngle + ra, hourAngle + ra]
    }
    
    /**
     The Local Time that the target rises above the given altitude.
     UTC = (-0.0657098 * d) - (1 / 15 * longitude) + (1 / 15 * LST) - (5023 / 750)
     where d = fractional days since J2000
     - Parameter location: The location at which the local time is being calculated for.
     - Parameter date: The date at which the local time is being calculated on.
     - Parameter lst: The local sidereal time that should be converted to local time.
     - Returns: Two dates representing the local time that the target is at lst today and tomorrow.
     */
    private func getLocalTime(location: SavedLocation, date: Date, sunData: SunData, lst: Double) -> [Date] {
        let dToday = Date.daysSinceJ2000(until: sunData.astronomicalTwilightBegin)
        let dTomorrow = Date.daysSinceJ2000(until: sunData.ATInterval.end)

        
        // calculate time in decimal hours and then convert to a date object on the current date
        var localTime: [Date] = [Date(), Date()]
        localTime[0] = ((-0.0657098 * dToday) - (1/15*location.longitude) + (1/15*lst) - (5023/750)).mod(by: 24).hoursToDate(on: date)
        localTime[1] = ((-0.0657098 * dTomorrow) - (1/15*location.longitude) + (1/15*lst) - (5023/750)).mod(by: 24).hoursToDate(on: date.tomorrow())
        return localTime
        
    }
    
    /**
     Gets the next interval that the target is in the sky, from rise to set.
     Next is defined as the next time the target rises after astronomical twilight begins on the current day.
     - Parameter location: The location with which to calculate the rise and set times.
     - Parameter date: The date on which to calculate the rise and set times.
     - Returns: A DateInterval object from the targets next rise to the targets next set.
     */
    func getNextInterval(at location: SavedLocation, on date: Date, sunData: SunData, limitingAlt: Double = 0) throws -> DateInterval {
        do {
            let riseToday = try getLocalTime(location: location, date: date, sunData: sunData, lst: getLST(location: location, from: limitingAlt)[0])[0]
            let setToday = try getLocalTime(location: location, date: date, sunData: sunData, lst: getLST(location: location, from: limitingAlt)[1])[0]
            let riseTomorrow = try getLocalTime(location: location, date: date, sunData: sunData, lst: getLST(location: location, from: limitingAlt)[0])[1]
            let setTomorrow = try getLocalTime(location: location, date: date, sunData: sunData, lst: getLST(location: location, from: limitingAlt)[1])[1]
            let dayStart = sunData.astronomicalTwilightBegin

            // if rise < set && rise > sunrise
            if riseToday < setToday && riseToday > dayStart {
                // set interval from riseToday to setToday
                return DateInterval(start: riseToday, end: setToday)
            }
            // if rise < set && rise < sunrise
            else if riseToday < setToday && riseToday < dayStart && riseTomorrow < setTomorrow {
                // set interval from riseTomorrow to setTomorrow
                return DateInterval(start: riseTomorrow, end: setTomorrow)
            }
            // hot fix for issues involving midnight (12/23/22)
            else if riseToday < setToday && riseToday < dayStart {
                return DateInterval(start: riseToday.tomorrow(), end: setTomorrow)
            }
            // if rise > set
            else {
                // set interval from riseToday to setTomorrow
                return DateInterval(start: riseToday, end: setTomorrow)
            }
        }
    }
    
    /**
     Gets the next time at which the target crosses the meridian.
     A target crosses the meridian when its right ascension is equal to the local sidereal time.
     - Parameter location: The location at which to calculate the meridian crossing.
     - Parameter date: The date on which to calculate the meridian crossing.
     - Returns: The date and time that the object next passes the meridian.
     */
    func getNextMeridian(at location: SavedLocation, on date: Date, sunData: SunData) -> Date {
        return getLocalTime(location: location, date: date, sunData: sunData, lst: ra)[1]
    }
    
    /**
     A measure of how much time the target will be visible during the night, calculated as the percent of the night that its visible for.
     It essentially calcualtes Night Overlap Time / Night Length Time.
     - Parameter location: The location at which to calculate the target's visibility.
     - Parameter date: The date on which to calculate the target's visibility.
     - Returns: A decimal representing the percentage of the night that the target is visible.
     
     */
    func getVisibilityScore(at location: SavedLocation, on date: Date, sunData: SunData, limitingAlt: Double) -> Double {
        // retrieve necessary data
        do {
            let targetInterval = try getNextInterval(at: location, on: date, sunData: sunData, limitingAlt: limitingAlt)
            
            let nightInterval = sunData.ATInterval
            
            // calculate time that the target is in the sky during the night
            guard let overlap = nightInterval.intersection(with: targetInterval) else {
                return 0
            }
            
            // calculate score
            return overlap.duration / nightInterval.duration
        } catch TargetCalculationError.neverRises {
            return 0
        } catch TargetCalculationError.neverSets {
            return 1
        } catch {
            return 0
        }

    }
    
    /**
     A measure of margin of error of the objects absolute value of the time between meridian crossing and "midnight."
     The calculation is Meridian score = 1 - abs(meridian crossing - midnight).
     - Parameter location: The location at which to calculate the meridian score.
     - Parameter date: The date on which to calculate the meridian score.
     - Returns: A decimal representing an abstract percentage.
     */
    func getMeridianScore(at location: SavedLocation, on date: Date, sunData: SunData) -> Double {
        let targetMeridian = getNextMeridian(at: location, on: date, sunData: sunData)
        let nightLength = sunData.ATInterval.duration
        let nightBegin = sunData.ATInterval.start
        
        let midnight = nightBegin.addingTimeInterval(Double(nightLength/2))
        if (targetMeridian < midnight){
            let interval = DateInterval(start: targetMeridian, end: midnight).duration/60/60/24
            return 1 - interval
        } else {
            let interval = DateInterval(start: midnight, end: targetMeridian).duration/60/60/24
            return 1 - interval
        }
    }
}

extension DeepSkyTarget: Codable {
    
    struct RANum: Codable {
        let hour: Int
        let minute: Int
        let second: Double
        var decimal: Double {
            get {
                return (Double(hour) + (Double(minute) / 60) + (second / 3600))*15
            }
        }
    }

    struct DecNum: Codable {
        let degree: Int
        let minute: Int
        let second: Double
        var decimal: Double {
            get {
                if (degree > 0) {
                    return Double(degree) + (Double(minute) / 60) + (second / 3600)
                } else {
                    return Double(degree) - (Double(minute) / 60) - (second / 3600)
                }
            }
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode([String].self, forKey: .name)
        self.designation = try container.decode([Designation].self, forKey: .designation)
        self.image = try container.decode(TargetImage.self, forKey: .image)
        self.description = try container.decode(String.self, forKey: .description)
        self.descriptionURL = try container.decode(URL.self, forKey: .descriptionURL)
        self.type = try container.decode([DSOType].self, forKey: .type)
        self.constellation = try container.decode(Constellation.self, forKey: .constellation)
        self.ra = try container.decode(RANum.self, forKey: .ra).decimal
        self.dec = try container.decode(DecNum.self, forKey: .dec).decimal
        self.arcLength = try container.decode(Double.self, forKey: .arcLength)
        self.arcWidth = try container.decode(Double.self, forKey: .arcWidth)
        self.apparentMag = try container.decode(Double.self, forKey: .apparentMag)
    }
}
