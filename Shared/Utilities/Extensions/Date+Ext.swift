//
//  Date.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/11/22.
//

import Foundation

// DeepSkyCore Functions
extension Date {
    /// The J2000 Epoch on January 1, 2000 at 12:00 UTC
    static let J2000: Date = Date(timeIntervalSince1970: 946_728_000)
    
    /**
     Calculates the days between the Epoch J2000 and a given date.
     - Parameter until: The date to calculate the interval to.
     */
    static func daysSinceJ2000(until date: Date = Date.now) -> Double {
        if date > Date.J2000 {
            return DateInterval(start: Date.J2000, end: date).duration/60/60/24
        } else {
            return (DateInterval(start: date, end: Date.J2000).duration/60/60/24) * -1
        }
    }
    
    /**
     Extracts the decimal hours from self using a given timezone.
     - Parameter location: Location to calculate the time at.
     - Returns: A Double representing decimal hours at the given timezone.
     */
    func dateToUTCHours(location: Location) -> Double {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = location.timezone
        
        let time = calendar.dateComponents([.hour, .minute, .second], from: self)
        let hours = Double(time.hour!) + Double(time.minute!) / 60 + Double(time.second!) / 3600
        var tz = Double(location.timezone.secondsFromGMT() / 3600)
        if location.timezone.secondsFromGMT() < 0 {
            tz = -tz
        }
        return (hours + tz).mod(by: 24)
    }
    
    /**
     - Returns: self at 12:00 AM
     */
    public func startOfLocalDay(timezone: TimeZone) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timezone
        return calendar.startOfDay(for: self)
    }
    
    /**
     - Returns: self at 11:59 PM
     */
    public func endOfLocalDay(timezone: TimeZone) -> Date {
        return self.addingTimeInterval(86400).startOfLocalDay(timezone: timezone).addingTimeInterval(-1)
    }
    
    /**
     - Returns: self at 12:00 PM
     */
    public func localNoon(timezone: TimeZone) -> Date {
        return self.startOfLocalDay(timezone: timezone).addingTimeInterval(43_200)
    }
}

// Functions only required by UI
extension Date {
    /// The farthest back that WeatherKit can provide data for - August 1, 2021
    static let weatherKitHistoricalLimit: Date = Date(timeIntervalSince1970: 1_627_776_000)
        
    /**
     - Returns: self + 1 day
     */
    func tomorrow() -> Date {
        return self.addingTimeInterval(86400)
    }
    
    /**
     - Returns: self - 1 day
     */
    func yesterday() -> Date {
        return self.addingTimeInterval(-86400)
    }
    
    /**
    - Returns: An array of date objects at every hour of the day, from noon today to noon the next day.
     */
    func getEveryHour() -> [Date] {
        var array: [Date] = []
        for hour in 0..<24 {
            array.append(self.addingTimeInterval(43200 + Double(3600*hour)))
        }
        array.append(self.addingTimeInterval(43200 + Double(3600*24) - 1))
        return array
    }
    
    func getEveryMonth() -> [Date] {
        var array: [Date] = []
        let year = Calendar.current.dateComponents([.year], from: self).year
        for month in 1..<13 {
            var dateComps = DateComponents()
            dateComps.year = year
            dateComps.month = month
            dateComps.day = 1
            array.append(Calendar.current.date(from: dateComps)!)
        }
        var dateComps = DateComponents()
        dateComps.year = year
        dateComps.month = 12
        dateComps.day = 31
        array.append(Calendar.current.date(from: dateComps)!)
        return array
    }

    /**
     Converts a Date object into a custom String representation.
     - Parameter format: The format to follow.
     - Returns: A String representation of the Date.
     */
    func formatted(format: String, timezone: TimeZone = .gmt) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timezone
        formatter.locale = .current
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension Date: Identifiable {
    public var id: Self {
        self
    }
}
