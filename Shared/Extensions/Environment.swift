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
private struct DataKey: EnvironmentKey {
    static let defaultValue: (sun: SunData, moon: MoonData)? = nil
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
    
    var data: (sun: SunData, moon: MoonData)? {
        get {
            self[DataKey.self]
        }
        set {
            self[DataKey.self] = newValue
        }
    }
}
