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
    let offset: Int
    let pixelSizeX: Double
    let pixelSizeY: Double
    let cameraName: String
    let setTemp: Double
    let ccdTemp: Double
    let telescopeName: String
    let focalLength: Double
    let focalRatio: Double
    let ra: Double
    let dec: Double
    let airMass: Double
    let elevation: Double
    let latitude: Double
    let longitude: Double
    let filterWheelName: String
    let filterName: String
    let rotation: Double
    let creationSoftware: String
    
    init (from path: URL) {
        let fits = try! FitsFile.read(contentsOf: path)!.prime.headerUnit
        var metadata: [String: String] = [:]
        for element in fits {
            metadata[element.keyword.rawValue] = element.value?.toString.trimmingCharacters(in: .punctuationCharacters.subtracting(["-", ")", "("]))
        }
        let formatter = DateFormatter()
        formatter.timeZone = .gmt
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        self.resolutionLength = Int(metadata["NAXIS1"]!)!
        self.resolutionWidth = Int(metadata["NAXIS2"]!)!
        self.imageType = metadata["IMAGETYP"]!
        self.exposureTime = Double(metadata["EXPTIME"]!)!
        let date = metadata["DATE-OBS"]!
        self.date = formatter.date(from: date)!
        self.binningX = Int(metadata["XBINNING"]!)!
        self.binningY = Int(metadata["YBINNING"]!)!
        self.gain = Int(metadata["GAIN"]!)!
        self.offset = Int(metadata["OFFSET"]!)!
        self.pixelSizeX = Double(metadata["XPIXSZ"]!)!
        self.pixelSizeY = Double(metadata["YPIXSZ"]!)!
        self.cameraName = metadata["INSTRUME"]!
        self.setTemp = Double(metadata["SET-TEMP"]!)!
        self.ccdTemp = Double(metadata["CCD-TEMP"]!)!
        self.telescopeName = metadata["TELESCOP"]!
        self.focalLength = Double(metadata["FOCALLEN"]!)!
        self.focalRatio = Double(metadata["FOCRATIO"]!)!
        self.ra = Double(metadata["RA"]!)!
        self.dec = Double(metadata["DEC"]!)!
        self.airMass = Double(metadata["AIRMASS"]!)!
        self.elevation = Double(metadata["SITEELEV"]!)!
        self.latitude = Double(metadata["SITELAT"]!)!
        self.longitude = Double(metadata["SITELONG"]!)!
        self.filterWheelName = metadata["FWHEEL"]!
        self.filterName = metadata["FILTER"]!
        self.rotation = Double(metadata["OBJCTROT"]!)!
        self.creationSoftware = metadata["SWCREATE"]!
    }
}
