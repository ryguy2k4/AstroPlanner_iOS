//
//  JournalImportManager.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 12/20/23.
//

import Foundation
import WeatherKit

final class JournalImportManager {
    let ninaImagePlan: CaptureSequenceList?
    let ninaLog: NINALogFile?
    let aptLog: APTLogFile?
    let fitsMetadata: [FITSKeywords]?
    let rawMetadata: [EXIFMetadata]?
    
    init(ninaImagePlan: CaptureSequenceList?, ninaLog: NINALogFile?, aptLog: APTLogFile?, fitsMetadata: [FITSKeywords]?, rawMetadata: [EXIFMetadata]?) {
        self.ninaImagePlan = ninaImagePlan
        self.ninaLog = ninaLog
        self.aptLog = aptLog
        self.fitsMetadata = fitsMetadata?.sorted(by: { one, two in
            one.date < two.date
        })
        self.rawMetadata = rawMetadata
    }
    
    
    func generate() async -> JournalEntry {
        // Create entry from NINA Image Plan, NINA Log, and ALL FITS Metadata
        if let ninaImagePlan, let ninaLog, let fitsMetadata {
            return await generate(ninaImagePlan: ninaImagePlan, ninaLog: ninaLog, fitsMetadata: fitsMetadata)
        }
        // Create Entry from NINA Log and ALL FITS Metadata
        else if let ninaLog, let fitsMetadata {
            return await generate(ninaLog: ninaLog, fitsMetadata: fitsMetadata)
        }
        // Create Entry from APT Log and ALL FITS Metadata
        else if let aptLog, let fitsMetadata {
            return await generate(aptLog: aptLog, fitsMetadata: fitsMetadata)
        }
        // Create Entry from APT Log and ALL EXIF Metadata
        else if let aptLog, let rawMetadata {
            return await generate(aptLog: aptLog, rawMetadata: rawMetadata)
        }
        // Not enough data to auto generate an entry
        else {
            return JournalEntry()
        }

    }
    
    // Create entry from NINA Image Plan, NINA Log, and ALL FITS Metadata
    func generate(ninaImagePlan: CaptureSequenceList, ninaLog: NINALogFile, fitsMetadata: [FITSKeywords]) async -> JournalEntry {
        // Create journal target
        let centerRA = fitsMetadata.first?.ra ?? ninaImagePlan.coordinates.ra
        let centerDec = fitsMetadata.first?.dec ?? ninaImagePlan.coordinates.dec
        let rotation = fitsMetadata.first?.rotation ?? ninaImagePlan.rotation
        let target: JournalTarget = JournalTarget(targetID: .init(targetName: ninaImagePlan.targetName), centerRA: centerRA, centerDEC: centerDec, rotation: rotation)
        let dso = DeepSkyTargetList.allTargets.first(where: {$0.name?.first == ninaImagePlan.targetName})
        
        // Create Target Image Plans
        let ccdTemp = fitsMetadata.map({$0.ccdTemp})
        let airMass = fitsMetadata.map({$0.airMass})
        let imagePlan: [JournalImageSequence] = ninaImagePlan.captureSequences.map({JournalImageSequence(imageType: $0.imageType, filterName: $0.filterType.name, exposureTime: $0.exposureTime, binX: $0.binning.x, binY: $0.binning.y, gain: $0.gain, offset: $0.offset, numCaptured: $0.progressExposureCount, numUsable: fitsMetadata.count, ccdTemp: ccdTemp, airmass: airMass)})
        
        // Create Location
        let location = Location(current: .init(latitude: fitsMetadata.first!.latitude, longitude: fitsMetadata.first!.longitude))
        
        // Create Date Intervals
        let setupInterval = DateInterval(start: ninaLog.startUpDate, end: ninaLog.lastLineDate)
        let imagingInterval = DateInterval(start: fitsMetadata.first!.date, end: fitsMetadata.last!.date)
        
        // Create Target Plan
        let sunData = Sun.sol.getNextInterval(location: location, date: setupInterval.start.startOfLocalDay(timezone: location.timezone))
        let visibilityScore = dso?.getVisibilityScore(at: location, viewingInterval: sunData.ATInterval, sunData: sunData, limitingAlt: 0)
        let seasonScore = dso?.getSeasonScore(at: location, on: setupInterval.start.startOfLocalDay(timezone: location.timezone), sunData: sunData)
        
        // Create Imaging Preset
        let journalGear = JournalImagingPreset(focalLength: fitsMetadata.first!.focalLength, pixelSize: fitsMetadata.first!.pixelSizeX, resolutionLength: fitsMetadata.first!.resolutionLength, resolutionWidth: fitsMetadata.first!.resolutionWidth)
        
        // Create Weather Data
        let weather = try? await WeatherService().weather(for: location.clLocation, including: .hourly(startDate: setupInterval.start, endDate: setupInterval.end))
        let moonIllumination = Moon.getMoonIllumination(date: setupInterval.start, timezone: .current)
        
        
        // create entry
        let entry = JournalEntry(setupInterval: setupInterval, weather: weather?.forecast, moonIllumination: moonIllumination, location: location, gear: journalGear, tags: [], target: target, imagingInterval: imagingInterval, visibilityScore: visibilityScore, seasonScore: seasonScore, imagePlan: imagePlan)
        return entry
    }
    
    // Create Entry from NINA Log and ALL FITS Metadata
    func generate(ninaLog: NINALogFile, fitsMetadata: [FITSKeywords]) async -> JournalEntry {
        return JournalEntry()
    }
    
    // Create Entry from APT Log and ALL FITS Metadata
    func generate(aptLog: APTLogFile, fitsMetadata: [FITSKeywords]) async -> JournalEntry {
        // Create Location
        let location = Location(current: .init(latitude: fitsMetadata.first!.latitude, longitude: fitsMetadata.first!.longitude))
        
        // Create Date Intervals
        let setupInterval = DateInterval(start: aptLog.startUpDate, end: aptLog.lastLineDate)
        let imagingInterval = DateInterval(start: fitsMetadata.first!.date, end: fitsMetadata.last!.date)
        
        // Create Imaging Preset
        let journalGear = JournalImagingPreset(focalLength: fitsMetadata.first!.focalLength, pixelSize: fitsMetadata.first!.pixelSizeX, resolutionLength: fitsMetadata.first!.resolutionLength, resolutionWidth: fitsMetadata.first!.resolutionWidth)
        
        // Create Weather Data
        let weather = try? await WeatherService().weather(for: location.clLocation, including: .hourly(startDate: setupInterval.start, endDate: setupInterval.end))
        let moonIllumination = Moon.getMoonIllumination(date: setupInterval.start, timezone: .current)
        
        
        // create entry
        let entry = JournalEntry(setupInterval: setupInterval, weather: weather?.forecast, moonIllumination: moonIllumination, location: location, gear: journalGear, tags: [], target: nil, imagingInterval: imagingInterval, visibilityScore: nil, seasonScore: nil, imagePlan: nil)
        return entry
    }
    
    // Create Entry from APT Log and ALL EXIF Metadata
    func generate(aptLog: APTLogFile, rawMetadata: [EXIFMetadata]) async -> JournalEntry {
        
        // Create Date Intervals
        let setupInterval = DateInterval(start: aptLog.startUpDate, end: aptLog.lastLineDate)
        
        // create entry
        let entry = JournalEntry(setupInterval: setupInterval, weather: nil, moonIllumination: nil, location: nil, gear: nil, tags: [], target: nil, imagingInterval: nil, visibilityScore: nil, seasonScore: nil, imagePlan: nil)
        return entry
    }
}
