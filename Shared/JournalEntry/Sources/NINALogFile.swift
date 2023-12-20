//
//  NINALogFile.swift
//  DeepSkyCatalog 
//
//  Created by Ryan Sponzilli on 12/15/23.
//

import Foundation

struct NINALogFile {
    let startUpDate: Date
    let lastLineDate: Date
    
    init?(from path: URL) {
        let formatter = DateFormatter()
        formatter.timeZone = .gmt
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let log = try? String(contentsOf: path, encoding: .utf8).components(separatedBy: "\n")
        if let log = log {
            let startUpDate = String(log[3].trimmingCharacters(in: .punctuationCharacters).prefix(19))
            let lastLineDate = String(log.last(where: {$0.prefix(19).contains("T")})!.prefix(19))
            if let startUpDate = formatter.date(from: startUpDate), let lastLineDate = formatter.date(from: lastLineDate) {
                self.startUpDate = startUpDate
                self.lastLineDate = lastLineDate
            } else { return nil }
        } else { return nil }
    }
}
