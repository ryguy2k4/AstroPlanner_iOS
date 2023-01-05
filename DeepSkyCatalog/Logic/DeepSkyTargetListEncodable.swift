//
//  DSTEncodable.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/4/23.
//

import Foundation

// create a constructor to turn a deepskytarget into an encodable deepskytarget
// deal with ra/dec denominations
// encode to json





//    init(from target: DeepSkyTarget) {
//        self.name = target.name
//
//        var desig: [DesignationEncodable] = []
//        for d in target.designation {
//            desig.append(.init(catalog: d.catalog.rawValue, number: d.number))
//        }
//        self.designation = desig
//
//        self.image = target.image
//        self.imageCopyright = target.imageCopyright
//        self.description = target.description
//        self.descriptionURL = target.descriptionURL
//
//        self.type = target.type.map({$0.rawValue})
//        self.constellation = target.constellation.rawValue
//        self.ra = target.ra
//        self.dec = target.dec
//        self.arcLength = target.arcLength
//        self.arcWidth = target.arcWidth
//        self.apparentMag = target.apparentMag
//    }

//    .onAppear() {
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .
//        //let keys: [String] = ["name", "age", "city"]
//        //encoder.outputKeys = keys
//        let encodableTargets = DeepSkyTargetList.allTargets.map({DeepSkyTargetEncodable(from: $0)})
//        for target in encodableTargets {
//            if let jsonData = try? encoder.encode(target), let jsonString = String(data: jsonData, encoding: .utf8) {
//                print(jsonString)
//            }
//        }
//    }
