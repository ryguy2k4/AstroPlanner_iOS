//
//  ProjectEntry.swift
//  DeepSkyCatalog 
//
//  Created by Ryan Sponzilli on 12/8/23.
//

import Foundation
import SwiftData

@Model class ProjectEntry {
    var target: UUID
    var totalIntegration: Double
    
    @Relationship(.unique, deleteRule: .nullify, inverse: \JournalEntry.projects)
    var imagingSessions: [JournalEntry]
    
    init(target: UUID, totalIntegration: Double, imagingSessions: [JournalEntry]) {
        self.target = target
        self.totalIntegration = totalIntegration
        self.imagingSessions = imagingSessions
    }
}
