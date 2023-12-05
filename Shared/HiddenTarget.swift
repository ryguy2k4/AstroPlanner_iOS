//
//  HiddenTarget.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 12/4/23.
//
//

import Foundation
import SwiftData

@Model class HiddenTarget {
    var id: UUID
    var origin: TargetSettings
    

    init(id: UUID, origin: TargetSettings) {
        self.id = id
        self.origin = origin
    }
    
}
