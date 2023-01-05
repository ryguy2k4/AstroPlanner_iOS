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
        return encodableData.map({$0.convertToDeepSkyTarget()})
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
    
    struct DesignationEncodable: Codable {
        let catalog: String
        let number: Int
    }
    
    struct raNum: Codable {
        let hour: Int
        let minute: Int
        let second: Double
        var decimal: Double {
            get {
                return (Double(hour) + (Double(minute) / 60) + (second / 3600))*15
            }
        }
    }

    struct decNum: Codable {
        let degree: Int
        let minute: Int
        let second: Double
        var decimal: Double {
            get {
                if (degree > 0) {
                    return Double(degree) + (Double(minute) / 60) + (second / 3600)
                } else {
                    return Double(degree) - (Double(minute) / 60) - (second / 3600)
                }
            }
        }
    }
    
    func convertToDeepSkyTarget() -> DeepSkyTarget {
        var designation: [Designation] = []
        for des in self.designation {
            designation.append(Designation(catalog: DSOCatalog(rawValue: des.catalog)!, number: des.number))
        }
        let constellation = Constellation(rawValue: self.constellation)!
        var type: [DSOType] = []
        for ty in self.type {
            type.append(DSOType(rawValue: ty)!)
        }
        
        // make ra from components
        let ra = Double((Double(self.ra.hour) + (Double(self.ra.minute) / 60) + (self.ra.second / 3600))*15)
        
        // make dec from components
        let dec = {
            if (self.dec.degree > 0) {
                return Double(Double(self.dec.degree) + (Double(self.dec.minute) / 60) + (self.dec.second / 3600))
            } else {
                return Double(Double(self.dec.degree) - (Double(self.dec.minute) / 60) - (self.dec.second / 3600))
            }
        }()
        
        return DeepSkyTarget(name: self.name, designation: designation, image: self.image, imageCopyright: self.imageCopyright, description: self.description, descriptionURL: self.descriptionURL, type: type, constellation: constellation, ra: ra, dec: dec, arcLength: self.arcLength, arcWidth: self.arcWidth, apparentMag: self.apparentMag)
    }
}
