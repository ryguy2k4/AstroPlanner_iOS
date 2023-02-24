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

private struct ViewingIntervalKey: EnvironmentKey {
    static let defaultValue: DateInterval = DateInterval(start: Date.today.addingTimeInterval(68400), end: Date.tomorrow.addingTimeInterval(18000))
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
    
    var viewingInterval: DateInterval {
        get {
            self[ViewingIntervalKey.self]
        }
        set {
            self[ViewingIntervalKey.self] = newValue
        }
    }
}
