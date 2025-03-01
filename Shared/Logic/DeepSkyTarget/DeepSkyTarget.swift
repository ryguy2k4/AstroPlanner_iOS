//
//  DeepSkyTarget.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/2/22.
//

import Foundation

/**
 The basic building block for this app. This struct defines a Deep Sky Target.
 */
struct DeepSkyTarget: Identifiable, Hashable {
    
    static let andromeda = DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == "FCFAF73B-D7FC-4732-919D-920EEDA0E5E7"})
    
    /// Unique identifier
    var id: UUID
    
    /// Common names for the target
    var name: [String]?
    
    /// A default name for a target composed of its type and designation
    var defaultName: String {
        get {
            name?.first ?? "\(type.rawValue) \(designation.first?.shortDescription ?? subDesignations.first?.shortDescription ?? "No Designation")"
        }
    }
    
    /// Catalog designations that this target has
    var designation: [Designation]
    
    /// Sub-classifications this target contains
    var subDesignations: [Designation]
    
    /// Sub-targets this target contains
    var subTargets: [UUID]
    
    /// An image for the target, including copyright information
    var image: TargetImage?
    
    /// A brief description of the target
    var description: String
    
    /// The target's wikipedia page, if it has one
    var wikipediaURL: URL?
    
    /// The type of target
    var type: TargetType
    
    /// The constellation the target resides in
    var constellation: Constellation
    
    /// The target's right ascension (J2000)
    var ra: Double
    
    /// The target's declination (J2000)
    var dec: Double
    
    /// The target's apparent angular length in the sky
    var arcLength: Double
    
    /// The target's apparent angular width in the sky
    var arcWidth: Double
    
    /// The target's apparent magnitude
    var apparentMag: Double?
    
    struct TargetImage: Hashable, Codable {
        var filename: String?
        var credit: String
        var apodID: String?
        
        var url: URL? {
            if let id = apodID {
                return URL(string: "https://apod.nasa.gov/apod/ap\(id).html")
            } else {
                return nil
            }
        }
    }

    struct Designation: Hashable, Codable {
        var catalog: TargetCatalog
        var number: Int
        var longDescription: String {
            get {
                return "\(catalog.rawValue) \(number)"
            }
        }
        var shortDescription: String {
            get {
                return "\(catalog.abbr)\(number)"
            }
        }
    }
    
    var subDesignationTargets: [DeepSkyTarget] {
        var array: [DeepSkyTarget] = []
        for item in subDesignations {
            array.append(contentsOf: DeepSkyTargetList.allTargets.filter({ target in
                target.designation.contains(where: {$0 == item})
            }))
        }
        return Array(Set(array)).sortedBySize()
    }
    
    var designationDescription: String {
        var string = "\(defaultName) is designated as "
        if designation.count == 1 {
            string.append("\(designation[0].longDescription).")
        } else if designation.count == 2 {
            string.append("\(designation[0].longDescription) and \(designation[1].longDescription).")
        } else {
            for index in designation.indices {
                if index != designation.endIndex - 1 {
                    string.append("\(designation[index].longDescription), ")
                } else {
                    string.append("and \(designation[index].longDescription).")
                }
            }
        }
        
        return string
    }
}

/**
 All Functions performed on DeepSkyTargett
 */
extension DeepSkyTarget {
    
    struct TargetInterval {
        let antiCulmination: Date
        let culmination: Date
        let interval: TargetVisibility
        
        enum TargetVisibility {
            case never
            case always
            case sometimes(DateInterval)
        }
        
    }
    
    /**
     Gets the altitude of the target at a specific time
     Used for altitude graphs
     - Parameter location: The location to calculate the altitude at.
     - Parameter time: The time to calculate the altitude at.
     - Returns: The altitude of the target at the given time and location measured in degrees.
     
     LST = 100.46 + 0.985647 * d + long + 15*UT
     HA = LST - RA
     sin(ALT) = sin(DEC)*sin(LAT)+cos(DEC)*cos(LAT)*cos(HA)
     */
    func getAltitude(location: Location, time: Date) -> Double {
        let d = Date.daysSinceJ2000(until: time)
        let lst = 100.46 + (0.985647 * d) + location.longitude + (15 * time.dateToUTCHours(location: location)).mod(by: 360)
        let ha = (lst - ra).mod(by: 360)
        let sinAlt = sin(dec.toRadian()) * sin(location.latitude.toRadian()) + cos(dec.toRadian()) * cos(location.latitude.toRadian()) * cos(ha.toRadian())
        return asin(sinAlt).toDegree()
    }
    
    /**
     This function searches through the altitude function of this target looking for a certain condition to be satisfied
     - Parameter startTime: The time to begin the altitude search at
     - Parameter initialIncrement: The initial amount to increment altitude sampling times
     - Parameter finalIncrement: The level of precision to hone in on the exact time
     - Parameter condition: The condition that is satisfied when the time being searched for has not been found yet
     */
   static private func binaryAltitudeSearch(startTime: Date, initialIncrement: TimeInterval, finalIncrement: TimeInterval, condition: (Date, TimeInterval) -> Bool) -> Date {
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
    
    /**
     Calculates the time on the interval [noon today, noon tomorrow] that the target reaches its highest altitude
     - Parameter location: The location on Earth to calculate from
     - Parameter date: The date on which to calculate the culmination
     - Returns: The time at which the target reaches its highest altitude
     */
    private func getCulmination(location: Location, date: Date) -> Date {
        let time = DeepSkyTarget.binaryAltitudeSearch(startTime: date.localNoon(timezone: location.timezone), initialIncrement: 21_600, finalIncrement: 60) { time, increment in
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
    
    /**
     Gets the next interval that the target is in the sky, from rise to set.
     Next is defined as the next time the target rises after astronomical twilight begins on the current day.
     - Parameter location: The location with which to calculate the rise and set times.
     - Parameter date: The date on which to calculate the rise and set times.
     - Returns: A TargetInterval object
     */
    func getNextInterval(location: Location, date: Date, limitingAlt: Double = 0) -> TargetInterval {
        
        let culmination = getCulmination(location: location, date: date)
        let antiCulmination = culmination.addingTimeInterval(-43_080)
        
        guard getAltitude(location: location, time: culmination) > limitingAlt else {
            return TargetInterval(antiCulmination: antiCulmination, culmination: culmination, interval: .never)
        }
        
        guard getAltitude(location: location, time: antiCulmination) < limitingAlt else {
            return TargetInterval(antiCulmination: antiCulmination, culmination: culmination, interval: .always)
        }
        
        // search for the next rise time after the anti-culmination
        let rise = DeepSkyTarget.binaryAltitudeSearch(startTime: antiCulmination, initialIncrement: 21_600, finalIncrement: 60) { time, increment in
            getAltitude(location: location, time: time) < limitingAlt && getAltitude(location: location, time: time.addingTimeInterval(increment)) < limitingAlt
        }
        
        // search for the next set time after the culmination
        let set = DeepSkyTarget.binaryAltitudeSearch(startTime: culmination, initialIncrement: 21_600, finalIncrement: 60) { time, increment in
            getAltitude(location: location, time: time) > limitingAlt && getAltitude(location: location, time: time.addingTimeInterval(increment)) > limitingAlt
        }
        
        return TargetInterval(antiCulmination: antiCulmination, culmination: culmination, interval: .sometimes(DateInterval(start: rise, end: set)))
    }
    
    /**
     A measure of how much time the target will be visible during the night, calculated as the percent of the night that its visible for.
     It essentially calcualtes Night Overlap Time / Night Length Time.
     - Parameter location: The location at which to calculate the target's visibility.
     - Parameter date: The date on which to calculate the target's visibility.
     - Returns: A decimal representing the percentage of the night that the target is visible.
     
     */
    func getVisibilityScore(at location: Location, viewingInterval: DateInterval, limitingAlt: Double) -> Double {
        // attempt to get target interval
        let targetInterval = getNextInterval(location: location, date: viewingInterval.start, limitingAlt: limitingAlt).interval
                    
        // calculate time that the target is in the sky during the night
        
        guard viewingInterval.duration != 0 else {
            return 0
        }
        
        switch targetInterval {
        case .never:
            return 0
        case .always:
            return 1
        case .sometimes(let interval):
            return (viewingInterval.intersection(with: interval)?.duration ?? 0) / viewingInterval.duration
        }
        
    }
    
    /**
     A measure of margin of error of the objects absolute value of the time between meridian crossing and "midnight."
     The calculation is Meridian score = 1 - abs(meridian crossing - midnight).
     - Parameter location: The location at which to calculate the meridian score.
     - Parameter date: The date on which to calculate the meridian score.
     - Returns: A decimal representing an abstract percentage.
     */
    func getSeasonScore(at location: Location, on date: Date, sunData: SunData) -> Double {
        let targetMeridian = getCulmination(location: location, date: date)

        if (targetMeridian < sunData.solarMidnight){
            // time between meridian crossing and midnight in fractional days
            let interval = DateInterval(start: targetMeridian, end: sunData.solarMidnight).duration/60/60/24
            return (1 - (interval / 0.5)).magnitude
        } else {
            let interval = DateInterval(start: sunData.solarMidnight, end: targetMeridian).duration/60/60/24
            return (1 - (interval / 0.5)).magnitude
        }
    }
    
    func getApproxSeasonScore(at location: Location, on date: Date) -> Double {
        let targetMeridian = getCulmination(location: location, date: date)
        
        let midnight = date.endOfLocalDay(timezone: location.timezone).addingTimeInterval(1)
        if (targetMeridian < midnight){
            // time between meridian crossing and midnight in fractional days
            let interval = DateInterval(start: targetMeridian, end: midnight).duration/60/60/24
            return (1 - (interval / 0.5)).magnitude
        } else {
            let interval = DateInterval(start: midnight, end: targetMeridian).duration/60/60/24
            return (1 - (interval / 0.5)).magnitude
        }
    }
}

/**
 A Codable Implementation for DeepSkyObject
 */
extension DeepSkyTarget: Codable {

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try? container.decode([String].self, forKey: .name)
        self.designation = try container.decode([Designation].self, forKey: .designation)
        self.subDesignations = try container.decode([Designation].self, forKey: .subDesignations)
        self.subTargets = try container.decode([UUID].self, forKey: .subTargets)
        self.image = try? container.decode(TargetImage.self, forKey: .image)
        self.description = try container.decode(String.self, forKey: .description)
        self.wikipediaURL = try? container.decode(URL.self, forKey: .wikipediaURL)
        self.type = try container.decode(TargetType.self, forKey: .type)
        self.constellation = try container.decode(Constellation.self, forKey: .constellation)
        self.ra = try container.decode(Double.self, forKey: .ra)
        self.dec = try container.decode(Double.self, forKey: .dec)
        self.arcLength = try container.decode(Double.self, forKey: .arcLength)
        self.arcWidth = try container.decode(Double.self, forKey: .arcWidth)
        self.apparentMag = try? container.decode(Double.self, forKey: .apparentMag)
    }
    
    enum CodingKeys: String, CodingKey {
        case name, id, designation, subDesignations, subTargets, image, description, wikipediaURL, type, constellation, ra, dec, arcLength, arcWidth, apparentMag
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        if let name = self.name {
            try container.encode(name, forKey: .name)
        }
        try container.encode(designation, forKey: .designation)
        try container.encode(subDesignations, forKey: .subDesignations)
        try container.encode(subTargets, forKey: .subTargets)
        if let image = self.image {
            try container.encode(image, forKey: .image)
        }
        try container.encode(description, forKey: .description)
        if let wikipediaURL = self.wikipediaURL {
            try container.encode(wikipediaURL, forKey: .wikipediaURL)
        }
        try container.encode(type, forKey: .type)
        try container.encode(constellation, forKey: .constellation)
        try container.encode(ra, forKey: .ra)
        try container.encode(dec, forKey: .dec)
        try container.encode(arcLength, forKey: .arcLength)
        try container.encode(arcWidth, forKey: .arcWidth)
        if let apparentMag = self.apparentMag {
            try container.encode(apparentMag, forKey: .apparentMag)
        }
    }
}

struct AstrometryJobInfo: Codable, Hashable {
    let calibration: AstrometryCalibration
    
    struct AstrometryCalibration: Codable, Hashable {
        let ra: Double
        let dec: Double
        let radius: Double
        let pixscale: Double
        let orientation: Double
        let parity: Double
    }
}

/**
 A Static Implementation of all functions performed on DeepSkyTarget
 These static functions are only used by the Journal
 */
extension DeepSkyTarget {
    
    /**
     Gets the altitude of the target at a specific time
     Used for altitude graphs
     - Parameter location: The location to calculate the altitude at.
     - Parameter time: The time to calculate the altitude at.
     - Returns: The altitude of the target at the given time and location measured in degrees.
     
     LST = 100.46 + 0.985647 * d + long + 15*UT
     HA = LST - RA
     sin(ALT) = sin(DEC)*sin(LAT)+cos(DEC)*cos(LAT)*cos(HA)
     */
    static func getAltitude(location: Location, time: Date, ra: Double, dec: Double) -> Double {
        let d = Date.daysSinceJ2000(until: time)
        let lst = 100.46 + (0.985647 * d) + location.longitude + (15 * time.dateToUTCHours(location: location)).mod(by: 360)
        let ha = (lst - ra).mod(by: 360)
        let sinAlt = sin(dec.toRadian()) * sin(location.latitude.toRadian()) + cos(dec.toRadian()) * cos(location.latitude.toRadian()) * cos(ha.toRadian())
        return asin(sinAlt).toDegree()
    }
    
    /**
     Calculates the time on the interval [noon today, noon tomorrow] that the target reaches its highest altitude
     - Parameter location: The location on Earth to calculate from
     - Parameter date: The date on which to calculate the culmination
     - Returns: The time at which the target reaches its highest altitude
     */
    static private func getCulmination(location: Location, date: Date, ra: Double, dec: Double) -> Date {
        let time = DeepSkyTarget.binaryAltitudeSearch(startTime: date.localNoon(timezone: location.timezone), initialIncrement: 21_600, finalIncrement: 60) { time, increment in
            slope(location: location, time: time, ra: ra, dec: dec) > 0 || slope(location: location, time: time.addingTimeInterval(increment), ra: ra, dec: dec) < 0
        }
        
        return time
        
        /**
         - Returns: An approximate IROC for altitude vs time at the given time in degrees per second
         */
        func slope(location: Location, time: Date, ra: Double, dec: Double) -> Double {
           let alt1 = getAltitude(location: location, time: time, ra: ra, dec: dec)
           let alt2 = getAltitude(location: location, time: time.addingTimeInterval(1), ra: ra, dec: dec)
           return alt1 - alt2
        }
    }
    
    /**
     Gets the next interval that the target is in the sky, from rise to set.
     Next is defined as the next time the target rises after astronomical twilight begins on the current day.
     - Parameter location: The location with which to calculate the rise and set times.
     - Parameter date: The date on which to calculate the rise and set times.
     - Returns: A DateInterval object from the targets next rise to the targets next set.
     */
    static func getNextInterval(location: Location, date: Date, limitingAlt: Double = 0, ra: Double, dec: Double) -> TargetInterval {
        
        let culmination = getCulmination(location: location, date: date, ra: ra, dec: dec)
        let antiCulmination = culmination.addingTimeInterval(-43_080)
        
        guard getAltitude(location: location, time: culmination, ra: ra, dec: dec) > limitingAlt else {
            return TargetInterval(antiCulmination: antiCulmination, culmination: culmination, interval: .never)
        }
        
        guard getAltitude(location: location, time: antiCulmination, ra: ra, dec: dec) < limitingAlt else {
            return TargetInterval(antiCulmination: antiCulmination, culmination: culmination, interval: .always)
        }
        
        // search for the next rise time after the anti-culmination
        let rise = binaryAltitudeSearch(startTime: antiCulmination, initialIncrement: 21_600, finalIncrement: 60) { time, increment in
            getAltitude(location: location, time: time, ra: ra, dec: dec) < limitingAlt && getAltitude(location: location, time: time.addingTimeInterval(increment), ra: ra, dec: dec) < limitingAlt
        }
        
        // search for the next set time after the culmination
        let set = binaryAltitudeSearch(startTime: culmination, initialIncrement: 21_600, finalIncrement: 60) { time, increment in
            getAltitude(location: location, time: time, ra: ra, dec: dec) > limitingAlt && getAltitude(location: location, time: time.addingTimeInterval(increment), ra: ra, dec: dec) > limitingAlt
        }
        
        return TargetInterval(antiCulmination: antiCulmination, culmination: culmination, interval: .sometimes(DateInterval(start: rise, end: set)))
    }
    
    /**
     A measure of how much time the target will be visible during the night, calculated as the percent of the night that its visible for.
     It essentially calcualtes Night Overlap Time / Night Length Time.
     - Parameter location: The location at which to calculate the target's visibility.
     - Parameter date: The date on which to calculate the target's visibility.
     - Returns: A decimal representing the percentage of the night that the target is visible.
     
     */
    static func getVisibilityScore(at location: Location, viewingInterval: DateInterval, limitingAlt: Double, ra: Double, dec: Double) -> Double {
        // attempt to get target interval
        let targetInterval = getNextInterval(location: location, date: viewingInterval.start.addingTimeInterval(-43_200), limitingAlt: limitingAlt, ra: ra, dec: dec).interval
                    
        // calculate time that the target is in the sky during the night
        
        guard viewingInterval.duration != 0 else {
            return 0
        }
        
        switch targetInterval {
        case .never:
            return 0
        case .always:
            return 1
        case .sometimes(let interval):
            return (viewingInterval.intersection(with: interval)?.duration ?? 0) / viewingInterval.duration
        }
        
    }
    
    /**
     A measure of margin of error of the objects absolute value of the time between meridian crossing and "midnight."
     The calculation is Meridian score = 1 - abs(meridian crossing - midnight).
     - Parameter location: The location at which to calculate the meridian score.
     - Parameter date: The date on which to calculate the meridian score.
     - Returns: A decimal representing an abstract percentage.
     */
    static func getSeasonScore(at location: Location, on date: Date, sunData: SunData, ra: Double, dec: Double) -> Double {
        let targetMeridian = getCulmination(location: location, date: date, ra: ra, dec: dec)

        if (targetMeridian < sunData.solarMidnight){
            // time between meridian crossing and midnight in fractional days
            let interval = DateInterval(start: targetMeridian, end: sunData.solarMidnight).duration/60/60/24
            return (1 - (interval / 0.5)).magnitude
        } else {
            let interval = DateInterval(start: sunData.solarMidnight, end: targetMeridian).duration/60/60/24
            return (1 - (interval / 0.5)).magnitude
        }
    }
    
    static func getApproxSeasonScore(at location: Location, on date: Date, ra: Double, dec: Double) -> Double {
        let targetMeridian = getCulmination(location: location, date: date, ra: ra, dec: dec)
        
        let midnight = date.endOfLocalDay(timezone: location.timezone).addingTimeInterval(1)
        if (targetMeridian < midnight){
            // time between meridian crossing and midnight in fractional days
            let interval = DateInterval(start: targetMeridian, end: midnight).duration/60/60/24
            return (1 - (interval / 0.5)).magnitude
        } else {
            let interval = DateInterval(start: midnight, end: targetMeridian).duration/60/60/24
            return (1 - (interval / 0.5)).magnitude
        }
    }
}
