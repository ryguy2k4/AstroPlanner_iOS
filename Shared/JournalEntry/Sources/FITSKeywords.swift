//
//  FITSKeywords.swift
//  DeepSkyCatalog 
//
//  Created by Ryan Sponzilli on 12/15/23.
//

import Foundation
import FITS

struct FITSKeywords {
    let bitpix: Int
    let naxis: Int
    let naxis1: Int
    let naxis2: Int
    let bzero: Int
    let imageType: String
    let exposure: Double
    let exposureTime: Double
    let dateLocation: String
    let dateObjective: String
    let binningX: Int
    let binningY: Int
    let gain: Int
    let offset: Int
    let pixelSizeX: Double
    let pixelSizeY: Double
    let camera: String
    let setTemp: Double
    let ccdTemp: Double
    let usbLimit: Int
    let telescope: String
    let focalLength: Double
    let focalRatio: Double
    let ra: Double
    let dec: Double
    let centerAltitude: Double
    let centerAzimuth: Double
    let airMass: Double
    let pierSide: String
    let siteElevation: Double
    let siteLatitude: Double
    let siteLongitude: Double
    let filterWheel: String
    let filter: String
    let objectRA: String
    let objectDec: String
    let objectRotation: Double
    let rowOrder: String
    let equinox: Double
    let creationSoftware: String
    
    init (from path: URL) {
        let fits = try! FitsFile.read(contentsOf: path)!.prime.headerUnit
        var metadata: [String: String] = [:]
        for element in fits {
            metadata[element.keyword.rawValue] = element.value?.toString.trimmingCharacters(in: .punctuationCharacters)
        }
        self.bitpix = Int(metadata["BITPIX"]!)!
        self.naxis = Int(metadata["NAXIS"]!)!
        self.naxis1 = Int(metadata["NAXIS1"]!)!
        self.naxis2 = Int(metadata["NAXIS2"]!)!
        self.bzero = Int(metadata["BZERO"]!)!
        self.imageType = metadata["IMAGETYP"]!
        self.exposure = Double(metadata["EXPOSURE"]!)!
        self.exposureTime = Double(metadata["EXPTIME"]!)!
        self.dateLocation = metadata["DATE-LOC"]!
        self.dateObjective = metadata["DATE-OBS"]!
        self.binningX = Int(metadata["XBINNING"]!)!
        self.binningY = Int(metadata["YBINNING"]!)!
        self.gain = Int(metadata["GAIN"]!)!
        self.offset = Int(metadata["OFFSET"]!)!
        self.pixelSizeX = Double(metadata["XPIXSZ"]!)!
        self.pixelSizeY = Double(metadata["YPIXSZ"]!)!
        self.camera = metadata["INSTRUME"]!
        self.setTemp = Double(metadata["SET-TEMP"]!)!
        self.ccdTemp = Double(metadata["CCD-TEMP"]!)!
        self.usbLimit = Int(metadata["USBLIMIT"]!)!
        self.telescope = metadata["TELESCOP"]!
        self.focalLength = Double(metadata["FOCALLEN"]!)!
        self.focalRatio = Double(metadata["FOCRATIO"]!)!
        self.ra = Double(metadata["RA"]!)!
        self.dec = Double(metadata["DEC"]!)!
        self.centerAltitude = Double(metadata["CENTALT"]!)!
        self.centerAzimuth = Double(metadata["CENTAZ"]!)!
        self.airMass = Double(metadata["AIRMASS"]!)!
        self.pierSide = metadata["PIERSIDE"]!
        self.siteElevation = Double(metadata["SITEELEV"]!)!
        self.siteLatitude = Double(metadata["SITELAT"]!)!
        self.siteLongitude = Double(metadata["SITELONG"]!)!
        self.filterWheel = metadata["FWHEEL"]!
        self.filter = metadata["FILTER"]!
        self.objectRA = metadata["OBJCTRA"]!
        self.objectDec = metadata["OBJCTDEC"]!
        self.objectRotation = Double(metadata["OBJCTROT"]!)!
        self.rowOrder = metadata["ROWORDER"]!
        self.equinox = Double(metadata["EQUINOX"]!)!
        self.creationSoftware = metadata["SWCREATE"]!
    }
}
