//
//  TargetType.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/10/22.
//

import Foundation

enum TargetType: String, Filter, CaseNameCodable {
    var id: Self { self }

    /// The name for this Filter
    static let name = "Type"
    
    // Broader groups of types used by DailyReport
    static let nebulae: Set<TargetType> = [.planetaryNebula, .supernovaRemnant, .reflectionNebula, .darkNebula, .HIIRegion, .mixedDiffuseNebulae, .cloudComplex]
    static let starClusters: Set<TargetType> = [.openStarCluster, .globularStarCluster, .starCloud, .asterism]
    static let galaxies: Set<TargetType> = [.ellipticalGalaxy, .spiralGalaxy, .irregularGalaxy, .galaxyGroup, .dwarfSpiralGalaxy, .dwarfIrregularGalaxy, .dwarfSpheroidalGalaxy, .peculiarGalaxy, .lenticularGalaxy, .barredSpiralGalaxy]
    // target imageable on moonless nights
    static let broadband: Set<TargetType> = galaxies.union([.reflectionNebula, .darkNebula, .mixedDiffuseNebulae, .cloudComplex])
    // targets imageable on moon nights
    static let narrowband: Set<TargetType> = starClusters.union([.HIIRegion, .supernovaRemnant, .planetaryNebula])

    // Nebulous
    case HIIRegion = "H II Region"
    case planetaryNebula = "Planetary Nebula"
    case supernovaRemnant = "Supernova Remnant"
    case reflectionNebula = "Reflection Nebula"
    case darkNebula = "Dark Nebula"
    
    // Galactic
    case ellipticalGalaxy = "Elliptical Galaxy"
    case lenticularGalaxy = "Lenticular Galaxy"
    case spiralGalaxy = "Spiral Galaxy"
    case barredSpiralGalaxy = "Barred Spiral Galaxy"
    case irregularGalaxy = "Irregular Galaxy"
    case dwarfSpheroidalGalaxy = "Dwarf Spheroidal Galaxy"
    case dwarfSpiralGalaxy = "Dwarf Spiral Galaxy"
    case dwarfIrregularGalaxy = "Dwarf Irregular Galaxy"
    case peculiarGalaxy = "Interacting Galaxies"
    case galaxyGroup = "Galaxy Group/Pair"
    
    // Stellar
    case openStarCluster = "Open Star Cluster"
    case globularStarCluster = "Globular Star Cluster"
    case starCloud = "Star Cloud"
    case asterism = "Asterism"
    
    // Other
    case cloudComplex = "Cloud Complex"
    case mixedDiffuseNebulae = "Mixed Diffuse Nebulae"
    case regionOfSky = "Region of Sky"
    case multiple = "Mixed Objects"
}
