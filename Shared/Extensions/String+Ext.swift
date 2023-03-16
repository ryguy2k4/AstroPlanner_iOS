//
//  String.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/11/22.
//

import Foundation

extension String {
    /**
     Converts a String representation of an ISO8601 Date into a Date object.
     - Returns: A Date object.
     */
    public func formatStringToDate(with format: String = "yyyy-MM-dd'T'HH:mm:ssZZZZZ", on date: Date? = nil) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeZone =  format.contains("yyyy-MM-dd'T'HH:mm:ssZZZZZ") ? TimeZone(abbreviation: "UTC") : .current
        dateFormatter.dateFormat = format
        if let date = date {
            dateFormatter.defaultDate = date
        }
       
        return dateFormatter.date(from: self)!
    }
}
