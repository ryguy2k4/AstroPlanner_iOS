//
//  JournalEntryList.swift
//  DeepSkyCatalog 
//
//  Created by Ryan Sponzilli on 11/29/23.
//

import Foundation
import SwiftData

struct JournalEntryList {
    static var allEntries: [JournalEntry] = {
        let decoder = JSONDecoder()
        let json = try! Data(contentsOf: URL(filePath: "/Users/ryansponzilli/Developer/DeepSkyCatalog/Shared/JournalEntry/Journal.json"))
        return try! decoder.decode([JournalEntry].self, from: json)
    }()
    
    static func exportObjects(list: [JournalEntry]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(list)
            if #available(macOS 13.0, *) {
                let path = URL(filePath: "/Users/ryansponzilli/Developer/DeepSkyCatalog/Shared/JournalEntry/Journal.json")
                try data.write(to: path)
               print("data exported")
            } else {
                // Fallback on earlier versions
            }

        } catch {
           print("error exporting: \(error)")
        }
    }
}
