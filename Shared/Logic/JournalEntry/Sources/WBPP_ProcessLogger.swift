//
//  WBPP_ProcessLogger.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 1/16/24.
//

import Foundation

struct WBPP_ProcessLogger {
    
    let masterLights: [Master]
//    let masterFlats: [Master]
//    let masterDarks: [Master]
    
    struct Master {
        var groupSize: Int
        var activeCount: Int
        var sizeX: Int
        var sizeY: Int
        var binning: Int
        var filter: String
        var exposure: Double
//        var keywords: [String]
        var mode: String
        var color: String
        
        fileprivate init(_ section: String) {
            let lines = section.components(separatedBy: "\n")
            let characterSet: CharacterSet = .letters.union(.punctuationCharacters).union(.whitespaces)
            self.groupSize = Int(lines[1].components(separatedBy: "(")[0].trimmingCharacters(in: characterSet))!
            self.activeCount = Int(lines[1].components(separatedBy: "(")[1].trimmingCharacters(in: characterSet))!
            
            var dict: [String: String] = [:]
            for line in lines where line.contains(":") {
                let components = line.components(separatedBy: ":").map({$0.trimmingCharacters(in: .whitespaces)})
                dict[components[0]] = components[1]
            }
            self.sizeX = Int(dict["SIZE"]!.components(separatedBy: "x")[0])!
            self.sizeY = Int(dict["SIZE"]!.components(separatedBy: "x")[1])!
            self.binning = Int(dict["BINNING"]!)!
            self.filter = dict["Filter"]!
            self.exposure = Double(dict["Exposure"]!.trimmingCharacters(in: .letters))!
            self.mode = dict["Mode"]!
            self.color = dict["Color"]!
        }
    }
    
    init(processLoggerPath: URL) throws {
        let logger = try String(contentsOf: processLoggerPath, encoding: .utf8).components(separatedBy: "\n*")
        let masterLights = logger.filter({$0.contains("IMAGE INTEGRATION")})
        
        self.masterLights = masterLights.map({Master($0)})
    }
}

/*
 ******************** IMAGE INTEGRATION ********************
 Group of 28 Light frames (28 active)
 SIZE  : 6224x4168
 BINNING  : 1
 Filter   : B
 Exposure : 300.00s
 Keywords : []
 Mode     : post-calibration
 Color    : mono

 Rejection method auto-selected: Generalized Extreme Studentized Deviate
 Integration completed: master Light saved at path D:/Astrophotography/Pleiades/master/masterLight_BIN-1_6224x4168_EXPOSURE-300.00s_FILTER-B_mono.xisf
 ***********************************************************
 
 ******************** MASTER FLAT GENERATION ********************
 Group of 20 Flat frames (20 active)
 SIZE  : 6224x4168
 BINNING  : 1
 Filter   : B
 Exposure : 0.03s
 Keywords : []
 Mode     : calibration
 Color    : mono

 Master Dark automatic match.

 Master bias: D:/Astrophotography/_Bias Library/Mono/masterBias_BIN-1_6224x4168.xisf
 Master dark: none
 Master flat: none

 Calibration completed: 20 Flat frames calibrated.
 Rejection method auto-selected: Generalized Extreme Studentized Deviate
 Integration completed: master Flat saved at path D:/Astrophotography/Pleiades/master/masterFlat_BIN-1_6224x4168_FILTER-B_mono.xisf
 ****************************************************************
 */
