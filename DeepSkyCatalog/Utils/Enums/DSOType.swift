//
//  DSOType.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/10/22.
//

import Foundation

enum DSOType: String, Filter, Codable {
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let type = try? container.decode(String.self)
        switch type {
        case "emissionNebula": self = .emissionNebula
            case "reflectionNebula": self = .reflectionNebula
            case "darkNebula": self = .darkNebula
            case "planetaryNebula": self = .planetaryNebula
            case "supernovaRemnant": self = .supernovaRemnant
            case "galaxy": self = .galaxy
            case "galaxyGroup": self = .galaxyGroup
            case "openStarCluster": self = .openStarCluster
            case "globularStarCluster": self = .globularStarCluster
            default: self = .emissionNebula
        }
    }
}
