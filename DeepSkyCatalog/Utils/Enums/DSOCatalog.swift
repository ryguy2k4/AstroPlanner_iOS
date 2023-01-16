//
//  DSOCatalog.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/21/22.
//

import Foundation
 
enum DSOCatalog: String, Filter, CaseNameCodable {
    static let name = "Catalog"
    var id: Self { self }
    case messier = "Messier"
    case caldwell = "Caldwell"
    case sh2 = "Sharpless 2"
    case barnard = "Barnard"
    case ngc = "NGC"
    case ic = "IC"
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
