//
//  TargetCalculationError.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/19/22.
//

import Foundation
import SwiftUI

enum TargetCalculationError: String, Error {
    case neverSets = "Target Never Sets"
    case neverRises = "Target Never Rises"
}
