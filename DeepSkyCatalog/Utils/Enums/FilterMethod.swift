//
//  FilterMethod.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/20/22.
//

import Foundation

enum FilterMethod {
    case search
    case catalog
    case constellation
    case type
    case magnitude
    case size
    case visibility
    case meridian
//    case ra
//    case dec

    
    
    var info: (name: String, icon: String) {
            switch self {
            case .search:
                return ("Search", "magnifyingglass")
            case .catalog:
                return ("Catalog", "list.star")
            case .constellation:
                return ("Constellation", "star")
            case .type:
                return ("Type", "atom")
            case .magnitude:
                return ("Magnitude", "sun.min.fill")
            case .size:
                return ("Size", "arrow.up.left.and.arrow.down.right")
            case .visibility:
                return ("Visibility", "eye.fill")
            case .meridian:
                return ("Meridian", "arrow.right.and.line.vertical.and.arrow.left")
            }
        }
}

protocol Filter: RawRepresentable<String>, Identifiable, Hashable, CaseIterable where AllCases == Array<Self> {
    static var name: String { get }
}
