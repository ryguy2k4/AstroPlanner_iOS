//
//  TargetType.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/10/22.
//

import Foundation

enum TargetType: String, Filter, CaseNameCodable {
    static let name = "Type"
    var id: Self { self }
    
    static let nebulae: [TargetType] = [.planetaryNebula, .supernovaRemnant, .reflectionNebula, .darkNebula, .emissionNebula]
    static let starClusters: [TargetType] = [.openStarCluster, .globularStarCluster]
    static let galaxies: [TargetType] = [.ellipticalGalaxy, .spiralGalaxy, .irregularGalaxy, .galaxyGroup]
    static let broadband: [TargetType] = [.ellipticalGalaxy, .spiralGalaxy, .irregularGalaxy, .darkNebula, .galaxyGroup, .reflectionNebula, .planetaryNebula]
    static let narrowband: [TargetType] = [.emissionNebula, .supernovaRemnant, .openStarCluster, .globularStarCluster]

    case emissionNebula = "Emission Nebula"
    case reflectionNebula = "Reflection Nebula"
    case darkNebula = "Dark Nebula"
    case planetaryNebula = "Planetary Nebula"
    case supernovaRemnant = "Supernova Remnant"
    case ellipticalGalaxy = "Elliptical Galaxy"
    case spiralGalaxy = "Spiral Galaxy"
    case irregularGalaxy = "Irregular Galaxy"
    case galaxyGroup = "Galaxy Group"
    case openStarCluster = "Open Star Cluster"
    case globularStarCluster = "Globular Star Cluster"
    case starCloud = "Star Cloud"
    case asterism = "Asterism"
}
