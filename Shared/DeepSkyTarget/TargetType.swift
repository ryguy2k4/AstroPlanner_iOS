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
    
    static let nebulae: [TargetType] = [.planetaryNebula, .supernovaRemnant, .reflectionNebula, .darkNebula, .HIIRegion, .mixedDiffuseNebulae]
    static let starClusters: [TargetType] = [.openStarCluster, .globularStarCluster]
    static let galaxies: [TargetType] = [.ellipticalGalaxy, .spiralGalaxy, .irregularGalaxy, .galaxyGroup]
    static let broadband: [TargetType] = [.ellipticalGalaxy, .spiralGalaxy, .irregularGalaxy, .darkNebula, .galaxyGroup, .reflectionNebula, .planetaryNebula, .mixedDiffuseNebulae]
    static let narrowband: [TargetType] = [.HIIRegion, .supernovaRemnant, .openStarCluster, .globularStarCluster]

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
    
    /*
     • Nebulous
         ○ Emission Nebula
             § H II Region
             § Planetary Nebula
             § Supernova Remnant
         ○ Reflection Nebula
         ○ Dark Nebula
     • Stellar
         ○ Open Star Cluster
         ○ Globular Star Cluster
         ○ Asterism
         ○ Star Cloud
     • Galactic
         ○ Elliptical Galaxy
         ○ Lenticular Galaxy
         ○ Spiral Galaxy
         ○ Barred Spiral Galaxy
         ○ Irregular Galaxy
         ○ Dwarf Galaxy
             § Dwarf Spheroidal / Dwarf Elliptical
             § Dwarf Spiral
             § Dwarf Irregular
         ○ Peculiar Galaxy / Interacting Galaxy
         ○ Galaxy Group
     • Other
         ○ Cloud Complex
         ○ Region of Sky
         ○ Multiple
     */
}
