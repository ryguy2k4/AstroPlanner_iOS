//
//  SortMethod.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/17/22.
//

import Foundation

enum SortMethod: CaseIterable, Identifiable {
    var id: Self { self }
    case visibility
    case meridian
    case dec
    case ra
    case magnitude
    
    var info: (name: String, icon: String) {
        switch self {
        case .visibility:
            return ("Visibility", "eye.fill")
        case .meridian:
            return ("Meridian", "arrow.right.and.line.vertical.and.arrow.left")
        case .dec:
            return ("Dec", "arrow.up.arrow.down")
        case .ra:
            return ("RA", "arrow.right.arrow.left")
        case .magnitude:
            return ("Magnitude", "sun.min.fill")
        }
    }
}
