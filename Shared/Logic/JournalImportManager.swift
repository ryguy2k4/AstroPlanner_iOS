//
//  JournalImportManager.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 12/20/23.
//

import Foundation
import WeatherKit

final class JournalImportManager {
    
    static func generate(ninaImagePlan: CaptureSequenceList?, ninaLog: NINALogFile?, fitsMetadata: [FITSKeywords]?, aptLog: APTLogFile?, rawMetadata: [EXIFMetadata]?) async -> JournalEntry {
                
        // Create journal target
        let centerRA = fitsMetadata?.first?.ra ?? ninaImagePlan?.coordinates.ra
        let centerDec = fitsMetadata?.first?.dec ?? ninaImagePlan?.coordinates.dec
        let rotation = fitsMetadata?.first?.rotation ?? ninaImagePlan?.rotation
        let target: JournalEntry.JournalTarget? = {
            if ninaImagePlan?.targetName != nil || centerRA != nil || centerDec != nil || rotation != nil {
                return .init(targetID: .init(targetName: ninaImagePlan?.targetName), centerRA: centerRA, centerDEC: centerDec, rotation: rotation)
            } else {
                return nil
            }
        }()
        
        // Create Target Image Plans
        let imagePlan: [JournalEntry.JournalImageSequence]? = {
            if let fitsMetadata = fitsMetadata {
                let ccdTemp = fitsMetadata.map({$0.ccdTemp})
                let airMass = fitsMetadata.map({$0.airMass})
                var filters: [String: [FITSKeywords]] = [:]
                for item in fitsMetadata {
                    if filters[item.filterName] == nil {
                        filters[item.filterName] = [item]
                    } else {
                        filters[item.filterName]?.append(item)
                    }
                }
                let fitsFilters = Array(filters.values)
                var imagePlan: [JournalEntry.JournalImageSequence] = []
                for sequence in fitsFilters {
                    let sameFilter = ninaImagePlan?.captureSequences.first(where: {$0.filterType.name == sequence.first?.filterName})
                    imagePlan.append(.init(filterName: sequence.first?.filterName, exposureTime: sequence.first?.exposureTime, binning: sequence.first?.binningX, gain: sequence.first?.gain, offset: sequence.first?.offset, ccdTemp: ccdTemp, airmass: airMass, numCaptured: sameFilter?.progressExposureCount, numUsable: sequence.count))
                }
                return imagePlan
            } else if let ninaImagePlan = ninaImagePlan {
                return ninaImagePlan.captureSequences.map({JournalEntry.JournalImageSequence(filterName: $0.filterType.name, exposureTime: $0.exposureTime, binning: $0.binning.x, gain: $0.gain, offset: $0.offset, ccdTemp: nil, airmass: nil, numCaptured: $0.progressExposureCount, numUsable: nil)})
            } else if let rawMetadata = rawMetadata {
                return rawMetadata.map({JournalEntry.JournalImageSequence(filterName: nil, exposureTime: $0.exposureTime, binning: nil, gain: $0.iso, offset: nil, ccdTemp: nil, airmass: nil, numCaptured: nil, numUsable: 1)})
            } else {
                return nil
            }
        }()
        
        // Create Location
        let location: Location? = {
            if let lat = fitsMetadata?.first?.latitude, let long = fitsMetadata?.first?.longitude, let elevation = fitsMetadata?.first?.elevation {
                var location = Location(latitude: lat, longitude: long, elevation: elevation)
                LocationManager.getTimeZone(location: location.clLocation) { zone in
                    if let zone {
                        location.timezone = zone
                    }
                }
                return location
            } else {
                return nil
            }
        }()
        
        // Create Date Intervals
        let setupInterval: DateInterval? = {
            if let ninaLog = ninaLog {
                return DateInterval(start: ninaLog.startUpDate, end: ninaLog.lastLineDate)
            } else if let aptLog = aptLog {
                return DateInterval(start: aptLog.startUpDate, end: aptLog.lastLineDate)
            } else {
                return nil
            }
        }()
        let imagingInterval: DateInterval? = {
            if let first = fitsMetadata?.first, let last = fitsMetadata?.last {
                return DateInterval(start: first.date, end: last.date)
            } else if let first = rawMetadata?.first, let last = rawMetadata?.first {
                return DateInterval(start: first.dateTimeOriginal, end: last.dateTimeOriginal)
            } else {
                return nil
            }
        }()
        
        // Create Scores
        let scores: (vis: Double?, season: Double?) = {
            if let location = location, let setupInterval = setupInterval, let centerRA = centerRA, let centerDec = centerDec {
                let sunData = Sun.sol.getNextInterval(location: location, date: setupInterval.start.startOfLocalDay(timezone: location.timezone))
                let visibilityScore = DeepSkyTarget.getVisibilityScore(at: location, viewingInterval: sunData.ATInterval, limitingAlt: 0, ra: centerRA, dec: centerDec)
                let seasonScore = DeepSkyTarget.getSeasonScore(at: location, on: setupInterval.start.startOfLocalDay(timezone: location.timezone), sunData: sunData, ra: centerRA, dec: centerDec)
                return (vis: visibilityScore, season: seasonScore)
            }
            return (vis: nil, season: nil)
        }()
        
        // Create Imaging Preset
        let journalGear: JournalEntry.JournalGear? = {
            if let fitsMetadata = fitsMetadata?.first {
                return JournalEntry.JournalGear(focalLength: fitsMetadata.focalLength, pixelSize: fitsMetadata.pixelSizeX, resolutionLength: fitsMetadata.resolutionLength, resolutionWidth: fitsMetadata.resolutionWidth, telescopeName: fitsMetadata.telescopeName, filterWheelName: fitsMetadata.filterWheelName, mountName: nil, cameraName: fitsMetadata.cameraName, captureSoftware: fitsMetadata.creationSoftware)
            } else if let rawMetadata = rawMetadata?.first {
                return JournalEntry.JournalGear(focalLength: nil, pixelSize: nil, resolutionLength: rawMetadata.resolutionLength, resolutionWidth: rawMetadata.resolutionWidth, cameraName: rawMetadata.cameraModel)
            } else {
                return nil
            }
        }()
        
        // Create Weather Data
        let weather: (forecast: [HourWeather]?, moon: Double?) = await {
            if let setupInterval = setupInterval {
                let moonIllumination = Moon.getMoonIllumination(date: setupInterval.start)
                
                if let location = location {
                    let weather = try? await WeatherService().weather(for: location.clLocation, including: .hourly(startDate: setupInterval.start, endDate: setupInterval.end))
                    return (forecast: weather?.forecast, moon: moonIllumination)
                } else {
                    return (forecast: nil, moon: moonIllumination)
                }
            } else {
                return (forecast: nil, moon: nil)
            }
        }()
        
        
        // Create Entry
        let entry = JournalEntry(setupInterval: setupInterval, weather: weather.forecast, moonIllumination: weather.moon, location: location, gear: journalGear, tags: [], target: target, imagingInterval: imagingInterval, visibilityScore: scores.vis, seasonScore: scores.season, imagePlan: imagePlan)
        return entry
    }
}
