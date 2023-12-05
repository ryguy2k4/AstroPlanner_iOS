//
//  TargetSettings.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 12/4/23.
//
//

import Foundation
import SwiftData

@Model class TargetSettings {
    var hideNeverRises: Bool = false
    var limitingAltitude: Double = 0
    var hiddenTargets: [HiddenTarget] = []
    
    init(hideNeverRises: Bool, limitingAltitude: Double, hiddenTargets: [HiddenTarget]) {
        self.hideNeverRises = hideNeverRises
        self.limitingAltitude = limitingAltitude
        self.hiddenTargets = hiddenTargets
    }
    
}
