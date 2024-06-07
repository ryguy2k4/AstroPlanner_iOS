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
    let images: [String]
    
    init?(from path: URL) {
        let formatter = DateFormatter()
        formatter.timeZone = .gmt
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let log = try? String(contentsOf: path, encoding: .utf8).components(separatedBy: "\n")
        if let log {
            
            // Extract Setup Interval
            let startUpDate = String(log[3].trimmingCharacters(in: .punctuationCharacters).prefix(19))
            let lastLineDate = String(log.last(where: {$0.prefix(19).contains("T")})!.prefix(19))
            if let startUpDate = formatter.date(from: startUpDate), let lastLineDate = formatter.date(from: lastLineDate) {
                self.startUpDate = startUpDate
                self.lastLineDate = lastLineDate
            } else { return nil }
            
            // Extract Images Saved
            let imageSavedLines = log.filter({$0.contains("FinalizeSave") && $0.contains("LIGHT")})
            let urlStrings = imageSavedLines.map({$0.split(separator: "Saving image at ")[1]})
            let urls = urlStrings.map({URL(filePath: String($0))})
            self.images = urls.map({$0.lastPathComponent})
            
        } else { return nil }
    }
}
