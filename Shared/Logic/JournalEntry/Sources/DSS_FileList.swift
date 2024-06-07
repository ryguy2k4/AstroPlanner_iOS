//
//  DSS_FileList.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 1/20/24.
//

import Foundation

struct DSS_FileList {
    let images: [String]
    
    init(processLoggerPath: URL) throws {
        let log = try String(contentsOf: processLoggerPath, encoding: .utf8).components(separatedBy: "\n")
        let fileLines = log.filter({$0.contains("light")})
        let images = fileLines.map({String($0.suffix(from: $0.index($0.startIndex, offsetBy: 10)))})
        self.images = images
    }
}
