//
//  FITSKeywords.swift
//  DeepSkyCatalog 
//
//  Created by Ryan Sponzilli on 12/15/23.
//

import Foundation
import FITS

struct FITSKeywords {
    let resolutionLength: Int
    let resolutionWidth: Int
    let imageType: String
    let exposureTime: Double
    let date: Date
    let binningX: Int
    let binningY: Int
    let gain: Int
    let offset: Int?
    let pixelSizeX: Double
    let pixelSizeY: Double
    let cameraName: String
    let setTemp: Double
    let ccdTemp: Double
    let telescopeName: String
    let focalLength: Double
    let focalRatio: Double?
    let ra: Double
    let dec: Double
    let airMass: Double
    let elevation: Double?
    let latitude: Double
    let longitude: Double
    let filterWheelName: String?
    let filterName: String
    let rotation: Double?
    let creationSoftware: String
    
    init (from path: URL) {
        let fits = try! FitsFile.read(contentsOf: path)!.prime.headerUnit
        var metadata: [String: String] = [:]
        for element in fits {
            metadata[element.keyword.rawValue] = element.value?.toString.trimmingCharacters(in: .punctuationCharacters.subtracting(["-", ")", "("]))
        }
        let formatter1 = DateFormatter()
        formatter1.timeZone = .gmt
        formatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let formatter2 = DateFormatter()
        formatter2.timeZone = .gmt
        formatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        self.resolutionLength = Int(metadata["NAXIS1"]!)!
        self.resolutionWidth = Int(metadata["NAXIS2"]!)!
        self.imageType = metadata["IMAGETYP"]!
        self.exposureTime = Double(metadata["EXPTIME"]!)!
        let date = metadata["DATE-OBS"]!
        self.date = formatter1.date(from: date) ?? formatter2.date(from: date)!
        self.binningX = Int(metadata["XBINNING"]!)!
        self.binningY = Int(metadata["YBINNING"]!)!
//        if let gain = metadata["GAIN"], let gain = Int(gain) {
//            self.gain = gain
//        } else {
//            self.gain = nil
//        }
        self.gain = Int(metadata["GAIN"]!)!
        if let offset = metadata["OFFSET"], let offset = Int(offset) {
            self.offset = offset
        } else {
            self.offset = nil
        }
        self.pixelSizeX = Double(metadata["XPIXSZ"]!)!
        self.pixelSizeY = Double(metadata["YPIXSZ"]!)!
        self.cameraName = metadata["INSTRUME"]!
        self.setTemp = Double(metadata["SET-TEMP"]!)!
        self.ccdTemp = Double(metadata["CCD-TEMP"]!)!
        self.telescopeName = metadata["TELESCOP"]!
        self.focalLength = Double(metadata["FOCALLEN"]!)!
        if let focalRatio = metadata["FOCRATIO"], let focalRatio = Double(focalRatio) {
            self.focalRatio = focalRatio
        } else {
            self.focalRatio = nil
        }
        if let ra = metadata["RA"], let ra = Double(ra) {
            self.ra = ra
        } else {
            let raString = metadata["OBJCTRA"]!.split(separator: " ")
            self.ra = (Double(raString[0])! + Double(raString[1])!/60 + Double(raString[2])!/3600) * 15
        }
        if let dec = metadata["DEC"], let dec = Double(dec) {
            self.dec = dec
        } else {
            let decString = metadata["OBJCTDEC"]!.split(separator: " ")
            self.dec = Double(decString[0])! + Double(decString[1])!/60 + Double(decString[2])!/3600
        }
        self.airMass = Double(metadata["AIRMASS"]!)!
        if let elevation = metadata["SITEEVEL"], let elevation = Double(elevation) {
            self.elevation = elevation
        } else {
            elevation = nil
        }
        if let latitude = metadata["SITELAT"], let latitude = Double(latitude) {
            self.latitude = latitude
        } else {
            let latString = metadata["SITELAT"]!.split(separator: " ")
            self.latitude = Double(latString[0])! + Double(latString[1])!/60 + Double(latString[2])!/3600
        }
        if let longitude = metadata["SITELONG"], let longitude = Double(longitude) {
            self.longitude = longitude
        } else {
            let longString = metadata["SITELONG"]!.split(separator: " ")
            self.longitude = Double(longString[0])! + Double(longString[1])!/60 + Double(longString[2])!/3600
        }
        if let filterWheelName = metadata["FWHEEL"] {
            self.filterWheelName = filterWheelName
        } else {
            self.filterWheelName = nil
        }
        self.filterName = metadata["FILTER"]!
        if let rotation = metadata["OBJCTROT"], let rotation = Double(rotation) {
            self.rotation = rotation
        } else {
            self.rotation = nil
        }
        self.creationSoftware = metadata["SWCREATE"]!
    }
}
