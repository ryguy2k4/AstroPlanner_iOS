//
//  APTLogFile.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 12/20/23.
//

import Foundation

struct APTLogFile {
    let startUpDate: Date
    let lastLineDate: Date
    
    init?(from path: URL) {
        let formatter = DateFormatter()
        formatter.timeZone = .gmt
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let log = try? String(contentsOf: path, encoding: .utf8).components(separatedBy: "\n")
        if let log {
            let startUpDate = String(log.first(where: {$0.contains("UT")})!.dropFirst(24).prefix(19))
            let lastLineDate = String(log.last(where: {$0.contains("UT")})!.dropFirst(24).prefix(19))
            if let startUpDate = formatter.date(from: startUpDate), let lastLineDate = formatter.date(from: lastLineDate) {
                self.startUpDate = startUpDate
                self.lastLineDate = lastLineDate
            } else { return nil }
        } else { return nil }
    }
}
