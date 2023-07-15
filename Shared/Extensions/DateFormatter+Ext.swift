//
//  DateFormatter+Ext.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 7/14/23.
//

import Foundation

extension DateFormatter {
    
    static func longDateOnly(timezone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = timezone
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }
    
    static func shortTimeOnly(timezone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = timezone
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }
    
    static func shortDateOnly(timezone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = timezone
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
}
