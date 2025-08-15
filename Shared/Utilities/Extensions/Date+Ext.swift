//
//  Date.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/11/22.
//

import Foundation

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
