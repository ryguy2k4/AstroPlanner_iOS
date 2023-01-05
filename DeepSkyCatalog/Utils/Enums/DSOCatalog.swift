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
    case messier = "messier"
    case caldwell = "caldwell"
    case ngc = "ngc"
    case ic = "ic"
    case sh2 = "Sh2"
    case barnard = "barnard"
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
