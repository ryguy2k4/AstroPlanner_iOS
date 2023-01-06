//
//  DSOCatalog.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/21/22.
//

import Foundation
 
enum DSOCatalog: String, Filter, Codable {
    static let name = "Catalog"
    var id: Self { self }
    case messier = "Messier"
    case caldwell = "Caldwell"
    case ngc = "NGC"
    case ic = "IC"
    case sh2 = "Sharpless 2"
    case barnard = "Barnard"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let catalog = try? container.decode(String.self)
        switch catalog {
            case "messier": self = .messier
            case "caldwell": self = .caldwell
            case "ngc": self = .ngc
            case "ic": self = .ic
            case "sh2": self = .sh2
            case "barnard": self = .barnard
            default: self = .messier
        }
    }
}

struct Designation: Hashable, Codable {
    let catalog: DSOCatalog
    let number: Int
    var description: String {
        get {
            return "\(catalog.rawValue) \(number)"
        }
    }
}
