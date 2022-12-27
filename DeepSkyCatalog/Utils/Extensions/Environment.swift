//
//  Environment.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/6/22.
//

import Foundation
import SwiftUI

private struct DateKey: EnvironmentKey {
    static let defaultValue: Date = Date.today
}

extension EnvironmentValues {
    var date: Date {
        get {
            self[DateKey.self]
        }
        set {
            self[DateKey.self] = newValue
        }
    }
}
