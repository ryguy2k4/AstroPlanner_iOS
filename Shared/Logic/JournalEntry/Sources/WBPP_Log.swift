//
//  WBPP_Log.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 1/18/24.
//

import Foundation

struct WBPP_Log {
    let images: [URL]
    
    init(processLoggerPath: URL) throws {
        var logger = try String(contentsOf: processLoggerPath, encoding: .utf8).components(separatedBy: "\n")
        var images: [URL] = []
        while logger.contains(where: {$0.contains("* Begin integration of Light frames")}) {
            if let startIndex = logger.firstIndex(where: {$0.contains("* Begin integration of Light frames")}), let endIndex = logger[startIndex..<logger.endIndex].firstIndex(where: {$0.contains("* End integration of Light frames")}) {
                let newSection = logger[startIndex...endIndex]
                if newSection.contains(where: {$0.contains("Mode     : post-calibration")}), newSection.contains(where: {$0.contains("Generalized Extreme Studentized Deviate")}), let startIndex = newSection.firstIndex(where: {$0.contains("Pixel rejection counts:")}), let endIndex = newSection[startIndex..<newSection.endIndex].firstIndex(where: {$0.contains("Total :")}) {
                    let subSection = newSection[startIndex...endIndex]
                    for line in subSection where line.contains("LIGHT") {
                        images.append(URL(filePath: String(line.suffix(from: line.index(line.startIndex, offsetBy: 22)))))
                    }
                }
                logger.removeSubrange(startIndex...endIndex)
            }
        }
        
        self.images = images
    }
}
