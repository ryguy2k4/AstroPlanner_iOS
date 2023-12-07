//
//  ReportSettings.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 12/4/23.
//
//

import Foundation
import SwiftData

@Model class ReportSettings {
    var darknessThreshold: Int = 0
    var filterForMoonPhase: Bool = false
    var maxAllowedMoon: Double = 0.2
    var minFOVCoverage: Double = 0.1
    var minVisibility: Double = 0.6
    var preferBroadband: Bool = false

    init(darknessThreshold: Int = 0, filterForMoonPhase: Bool = false, maxAllowedMoon: Double = 0.2, minFOVCoverage: Double = 0.1, minVisibility: Double = 0.6, preferBroadband: Bool = false) {
        self.darknessThreshold = darknessThreshold
        self.filterForMoonPhase = filterForMoonPhase
        self.maxAllowedMoon = maxAllowedMoon
        self.minFOVCoverage = minFOVCoverage
        self.minVisibility = minVisibility
        self.preferBroadband = preferBroadband
    }
}
