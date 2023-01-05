//
//  DSOType.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/10/22.
//

import Foundation

enum DSOType: String, Filter {
    static let name = "Type"
    var id: Self { self }
    
    static let nebulae: [DSOType] = [.planetaryNebula, .supernovaRemnant, .reflectionNebula, .darkNebula, .emissionNebula]
    static let starClusters: [DSOType] = [.openStarCluster, .globularStarCluster]
    static let galaxies: [DSOType] = [.galaxy, .galaxyGroup]
    static let broadband: [DSOType] = [.galaxy, .darkNebula, .galaxyGroup, .reflectionNebula, .planetaryNebula]
    static let narrowband: [DSOType] = [.emissionNebula, .supernovaRemnant, .openStarCluster, .globularStarCluster]

    case emissionNebula = "emissionNebula"
    case reflectionNebula = "reflectionNebula"
    case darkNebula = "darkNebula"
    case planetaryNebula = "planetaryNebula"
    case supernovaRemnant = "supernovaRemnant"
    case galaxy = "galaxy"
    // ellpiticalGalaxy
    // spiralGalaxy
        // barredSpiralGalaxy
        // grandDesignSpiralGalaxy
        // flocculentSpiralGalaxy
    // irregularGalaxy
        // lenticularGalaxy
        // ringGalaxy
    case galaxyGroup = "galaxyGroup"
    case openStarCluster = "openStarCluster"
    case globularStarCluster = "globularStarCluster"
}
