//
//  DSOCatalog.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/21/22.
//

import Foundation
 
enum DSOCatalog: String, Filter {
    static let name = "Catalog"
    var id: Self { self }
    case messier = "Messier"
    case caldwell = "Caldwell"
    case ngc = "NGC"
    case ic = "IC"
    case sh2 = "Sharpless2"
    case barnard = "Barnard"
}

struct Designation: Hashable {
    let catalog: DSOCatalog
    let number: Int
    var description: String {
        get {
            return "\(catalog.rawValue) \(number)"
        }
    }
}
