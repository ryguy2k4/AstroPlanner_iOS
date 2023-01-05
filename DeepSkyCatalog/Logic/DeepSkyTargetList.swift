//
//  DeepSkyTargetList.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/7/22.
//

import Foundation
import Swift

struct DeepSkyTargetList {
    static var allTargets: [DeepSkyTarget] = {
        let decoder = JSONDecoder()
        let data = try! Data(contentsOf: Bundle.main.url(forResource: "Catalog", withExtension: "json")!)
        let encodableData = try! decoder.decode([DeepSkyTargetEncodable].self, from: data)
        return encodableData.map({DeepSkyTargetEncodable.convertToDeepSkyTarget(from: $0)})
    }()
}

struct DeepSkyTargetEncodable: Codable {
    // identifiers
    let name: [String]
    let designation: [DesignationEncodable]
    
    // image
    let image: String
    let imageCopyright: String?
    
    // description
    let description: String
    let descriptionURL: URL
    let type: [String]
    
    // characteristics
    let constellation: String
    let ra: raNum
    let dec: decNum
    let arcLength: Double
    let arcWidth: Double
    let apparentMag: Double
    
    struct DesignationEncodable: Hashable, Codable {
        let catalog: String
        let number: Int
    }
    
    static func convertToDeepSkyTarget(from item: Self) -> DeepSkyTarget {
            var designation: [Designation] = []
            for des in item.designation {
                designation.append(Designation(catalog: DSOCatalog(rawValue: des.catalog)!, number: des.number))
            }
            let constellation = Constellation(rawValue: item.constellation)!
            var type: [DSOType] = []
            for ty in item.type {
                type.append(DSOType(rawValue: ty)!)
            }
            return DeepSkyTarget(name: item.name, designation: designation, image: item.image, imageCopyright: item.imageCopyright, description: item.description, descriptionURL: item.descriptionURL, type: type, constellation: constellation, ra: item.ra, dec: item.dec, arcLength: item.arcLength, arcWidth: item.arcWidth, apparentMag: item.apparentMag)
    }
}
