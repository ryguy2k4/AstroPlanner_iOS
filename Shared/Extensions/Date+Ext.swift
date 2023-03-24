//
//  Date.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/11/22.
//

import Foundation

extension Date {
    
    /// The J2000 Epoch on January 1, 2000 at 12:00 UTC
    static let J2000 = Date(timeIntervalSince1970: 946_728_000)
    
    /// The farthest back that WeatherKit can provide data for - August 1, 2021
    static let weatherKitHistoricalLimit = Date(timeIntervalSince1970: 1_627_776_000)
    
    /// 12:00 AM on the current date
    static let today = Calendar.current.startOfDay(for: Date())
    
    /// 12:00 AM on tomorrow's date
    static let tomorrow = Calendar.current.startOfDay(for: Date().tomorrow())
        
    /**
     - Returns: self + 1 day
     */
    func tomorrow() -> Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    
    /**
     - Returns: self - 1 day
     */
    func yesterday() -> Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    
    /**
     Extracts the decimal hours from self using a given timezone.
     - Parameter location: Location to calculate the time at.
     - Returns: A Double representing decimal hours at the given timezone.
     */
    func dateToUTCHours(location: Location) -> Double {
        let time = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
        let hours = Double(time.hour!) + Double(time.minute!) / 60 + Double(time.second!) / 3600
        var tz = Double(location.timezone.secondsFromGMT() / 3600)
        if location.timezone.secondsFromGMT() < 0 {
            tz = -tz
        }
        return (hours + tz).mod(by: 24)
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
        let year = Calendar.current.dateComponents([.year], from: .now).year
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
    func formatted(format: String, timezone: Int16 = 0) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: Int(timezone)*60*60)
        formatter.locale = .current
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
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
     - Returns: self at 12:00 AM
     */
    public func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    /**
     - Returns: self at 11:59 PM
     */
    public func endOfDay() -> Date {
        return Calendar.current.startOfDay(for: self.tomorrow()).addingTimeInterval(-1)
    }
    
    public func noon() -> Date {
        return self.startOfDay().addingTimeInterval(43_200)
    }
}

extension Date: Identifiable {
    public var id: Self {
        self
    }
}
