//
//  DSOType.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/10/22.
//

import Foundation

enum DSOType: String, Filter, CaseNameCodable {
    static let name = "Type"
    var id: Self { self }
    
    static let nebulae: [DSOType] = [.planetaryNebula, .supernovaRemnant, .reflectionNebula, .darkNebula, .emissionNebula]
    static let starClusters: [DSOType] = [.openStarCluster, .globularStarCluster]
    static let galaxies: [DSOType] = [.galaxy, .galaxyGroup]
    static let broadband: [DSOType] = [.galaxy, .darkNebula, .galaxyGroup, .reflectionNebula, .planetaryNebula]
    static let narrowband: [DSOType] = [.emissionNebula, .supernovaRemnant, .openStarCluster, .globularStarCluster]

    case emissionNebula = "Emission Nebula"
    case reflectionNebula = "Reflection Nebula"
    case darkNebula = "Dark Nebula"
    case planetaryNebula = "Planetary Nebula"
    case supernovaRemnant = "Supernova Remnant"
    case galaxy = "Galaxy"
    // ellpiticalGalaxy
    // spiralGalaxy
        // barredSpiralGalaxy
        // grandDesignSpiralGalaxy
        // flocculentSpiralGalaxy
    // irregularGalaxy
        // lenticularGalaxy
        // ringGalaxy
    case galaxyGroup = "Galaxy Group"
    case openStarCluster = "Open Star Cluster"
    case globularStarCluster = "Globular Star Cluster"
}
