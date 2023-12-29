//
//  EXIFMetadata.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 12/20/23.
//

import Foundation
import ImageIO

struct EXIFMetadata {
    var cameraModel: String
    var exposureTime: Double
    var dateTimeOriginal: Date
    var iso: Int
    var resolutionWidth: Int
    var resolutionHeight: Int
        
    init(from path: URL) {
        let imageSource = CGImageSourceCreateWithURL(path as CFURL, nil)
        let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil)
        let imageDict = imageProperties! as NSDictionary
        let tiffModel = imageDict.value(forKey: "{TIFF}") as AnyObject
        let exifDict = imageDict.value(forKey: "{Exif}") as! NSDictionary
        
        let formatter = DateFormatter()
        formatter.timeZone = .gmt
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        
        self.cameraModel = tiffModel.value(forKey: kCGImagePropertyTIFFModel as String) as! String
        self.exposureTime = exifDict.value(forKey:kCGImagePropertyExifExposureTime as String) as! Double
        let dateTimeOriginal = exifDict.value(forKey: kCGImagePropertyExifDateTimeOriginal as String) as! String
        self.dateTimeOriginal = formatter.date(from: dateTimeOriginal)!
        let iso = exifDict.value(forKey: kCGImagePropertyExifISOSpeedRatings as String) as! [Int]
        self.iso = iso.first!
        self.resolutionWidth = exifDict.value(forKey: kCGImagePropertyExifPixelXDimension as String) as! Int
        self.resolutionHeight = exifDict.value(forKey: kCGImagePropertyExifPixelYDimension as String) as! Int
    }
}
