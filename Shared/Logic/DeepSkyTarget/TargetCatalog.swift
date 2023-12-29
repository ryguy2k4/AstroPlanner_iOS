//
//  TargetCatalog.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/21/22.
//

import Foundation
 
enum TargetCatalog: String, Filter, CaseNameCodable {
    var id: Self { self }

    /// The name for this Filter
    static let name = "Catalog"
    
    /// Astronomical object catalogs
    case messier = "Messier"
    case caldwell = "Caldwell"
    case sh2 = "Sharpless 2"
    case barnard = "Barnard"
    case ngc = "NGC"
    case ic = "IC"
    case arp = "Arp"
    
    /// The abbreiviation that should precede the catalog number
    var abbr: String {
        switch self {
        case .messier:
            return "M"
        case .caldwell:
            return "C "
        case .sh2:
            return "Sh2-"
        case .barnard:
            return "Barnard "
        case .ngc:
            return "NGC "
        case .ic:
            return "IC "
        case .arp:
            return "Arp "
        }
    }
}
