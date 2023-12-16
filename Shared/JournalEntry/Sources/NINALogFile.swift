//
//  NINALogFile.swift
//  DeepSkyCatalog 
//
//  Created by Ryan Sponzilli on 12/15/23.
//

import Foundation

struct NINALogFile {
    let startUpDate: String
    let lastLineDate: String
    
    init(from path: URL) {
        let log = try! String(contentsOf: path, encoding: .utf8).components(separatedBy: "\n")
        self.startUpDate = String(log[3].trimmingCharacters(in: .punctuationCharacters).prefix(19))
        self.lastLineDate = String(log.last(where: {$0.prefix(19).contains("T")})!.prefix(19))
    }
}
