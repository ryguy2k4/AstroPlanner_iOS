//
//  TargetCatalog.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/21/22.
//

import Foundation
 
enum TargetCatalog: String, Filter, CaseNameCodable {
    static let name = "Catalog"
    var id: Self { self }
    case messier = "Messier"
    case caldwell = "Caldwell"
    case sh2 = "Sharpless 2"
    case barnard = "Barnard"
    case ngc = "NGC"
    case ic = "IC"
    
    var abbr: String {
        switch self {
        case .messier:
            return "M"
        case .caldwell:
            return "C "
        case .sh2:
            return "SH2-"
        case .barnard:
            return "Barnard "
        case .ngc:
            return "NGC "
        case .ic:
            return "IC "
        }
    }
}
