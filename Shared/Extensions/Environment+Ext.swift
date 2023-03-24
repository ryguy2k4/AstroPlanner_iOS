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
private struct SunDataKey: EnvironmentKey {
    static let defaultValue: SunData? = nil
}

private struct ViewingIntervalKey: EnvironmentKey {
    static let defaultValue: DateInterval = DateInterval(start: Date.today.addingTimeInterval(68400), end: Date.tomorrow.addingTimeInterval(18000))
}

private struct LocationKey: EnvironmentKey {
    static let defaultValue: Location = Location(current: .init(latitude: 0, longitude: 0))
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
    
    var sunData: SunData? {
        get {
            self[SunDataKey.self]
        }
        set {
            self[SunDataKey.self] = newValue
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
    
    var location: Location {
        get {
            self[LocationKey.self]
        }
        set {
            self[LocationKey.self] = newValue
        }
    }
}
