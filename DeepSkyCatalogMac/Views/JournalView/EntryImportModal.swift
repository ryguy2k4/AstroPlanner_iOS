//
//  EntryImportModal.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 12/17/23.
//

import SwiftUI
import WeatherKit
import XMLParsing
import UniformTypeIdentifiers

struct EntryImportModal: View {
    @Environment(\.dismiss) var dismiss
    @State var creating = false
    @State var ninaImagePlanURL: URL? = nil
    @State var ninaLogFileURL: URL? = nil
    @State var APTLogFileURL: URL? = nil
    @State var fitsURLs: Set<URL>? = nil
    @State var rawURLs: Set<URL>? = nil
    @State var fileImporter = false
    @Binding var entries: [JournalEntry]
    var body: some View {
        if !creating {
            VStack {
                FileChooser(title: "Import NINA Log File", allowedContentTypes: [.init(filenameExtension: "log")!], resultURL: $ninaLogFileURL)
                    .disabled(APTLogFileURL != nil)
                FileChooser(title: "Import NINA Image Plan", allowedContentTypes: [.xml], resultURL: $ninaImagePlanURL)
                    .disabled(APTLogFileURL != nil)
                FileChooser(title: "Import APT Log File", allowedContentTypes: [.text], resultURL: $APTLogFileURL)
                    .disabled(ninaLogFileURL != nil || ninaImagePlanURL != nil)
                MultipleFileChooser(title: "Import FITS Files", allowedContentTypes: [.init(filenameExtension: "fits")!], resultURLs: $fitsURLs)
                    .disabled(rawURLs != nil)
                MultipleFileChooser(title: "Import RAW Files", allowedContentTypes: [.init(filenameExtension: "cr2")!], resultURLs: $rawURLs)
                    .disabled(fitsURLs != nil)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create New Entry") {
                        creating = true
                    }
                }
            }
            .frame(minWidth: 600, maxWidth: 1200, minHeight: 400,  maxHeight: 800)
        } else {
            ProgressView("Creating New Entry")
                .padding()
                .task {
                    // Create entry from NINA Image Plan, NINA Log, and ALL FITS Metadata
                    if let planURL = ninaImagePlanURL, let ninaImagePlanData = try? Data(contentsOf: planURL), let ninaImagePlan = try? XMLDecoder().decode(CaptureSequenceList.self, from: ninaImagePlanData), let logURL = ninaLogFileURL, let ninaLog = NINALogFile(from: logURL), let fitsMetadata: [FITSKeywords] = fitsURLs?.map({FITSKeywords(from: $0)}) {
                        
                        // Create journal target
                        let centerRA = fitsMetadata.first?.ra ?? ninaImagePlan.coordinates.ra
                        let centerDec = fitsMetadata.first?.dec ?? ninaImagePlan.coordinates.dec
                        let rotation = fitsMetadata.first?.rotation ?? ninaImagePlan.rotation
                        let target: JournalTarget = JournalTarget(targetID: .init(targetName: ninaImagePlan.targetName), centerRA: centerRA, centerDEC: centerDec, rotation: rotation)
                        let dso = DeepSkyTargetList.allTargets.first(where: {$0.name?.first == ninaImagePlan.targetName})
                        
                        // Create Target Image Plans
                        let ccdTemp = fitsMetadata.map({$0.ccdTemp}).mean()
                        let imagePlans: [JournalImageSequence] = ninaImagePlan.captureSequences.map({JournalImageSequence(imageType: .init(rawValue: $0.imageType), filterName: $0.filterType.name, exposureTime: $0.exposureTime, binning: .init(x: $0.binning.x, y: $0.binning.y), gain: $0.gain, offset: $0.offset, ccdTemp: ccdTemp, numCaptured: $0.progressExposureCount, numUsable: nil)})
                        
                        // Create Location
                        let location = JournalLocation(latitude: fitsMetadata.first!.latitude, longitude: fitsMetadata.first!.longitude, timezone: "CST", elevation: fitsMetadata.first!.elevation, bortle: nil)
                        
                        // Create Date Intervals
                        let setupInterval = DateInterval(start: ninaLog.startUpDate, end: ninaLog.lastLineDate)
                        let imagingInterval = DateInterval(start: fitsMetadata.first!.date, end: fitsMetadata.last!.date)
                        
                        // Create Target Plan
                        let location2 = Location(current: .init(latitude: location.latitude, longitude: location.longitude))
                        let sunData = Sun.sol.getNextInterval(location: location2, date: setupInterval.start.startOfLocalDay(timezone: TimeZone(identifier: location.timezone)!))
                        let visibilityScore = dso?.getVisibilityScore(at: location2, viewingInterval: sunData.ATInterval, sunData: sunData, limitingAlt: 0)
                        let seasonScore = dso?.getSeasonScore(at: location2, on: setupInterval.start.startOfLocalDay(timezone: TimeZone(identifier: location.timezone)!), sunData: sunData)
                        let targetPlan = JournalTargetPlan(target: target, imagingInterval: imagingInterval, visibilityScore: visibilityScore, seasonScore: seasonScore, imagePlan: imagePlans)
                        
                        // Create Imaging Preset
                        let journalGear = JournalImagingPreset(focalLength: fitsMetadata.first!.focalLength, pixelSize: fitsMetadata.first!.pixelSizeX, resolutionLength: fitsMetadata.first!.resolutionLength, resolutionWidth: fitsMetadata.first!.resolutionWidth)
                        
                        // Create Weather Data
                        let weather = try? await WeatherService().weather(for: location2.clLocation, including: .hourly(startDate: setupInterval.start, endDate: setupInterval.end))
                        let moonIllumination = Moon.getMoonIllumination(date: setupInterval.start, timezone: .current)
                        
                        
                        // create entry
                        let entry = JournalEntry(targetSet: [targetPlan], setupInterval: setupInterval, weather: weather?.forecast, moonIllumination: moonIllumination, location: location, gear: journalGear, tags: [])
                        entries.append(entry)
                        dismiss()
                    } 
//                    // Create Entry from NINA Log and ALL FITS Metadata
//                    else if {
//                        
//                    }
//                    // Create Entry from APT Log and ALL FITS Metadata
//                    else if {
//                        
//                    }
//                    // Create Entry from APT Log and ALL EXIF Metadata
//                    else if {
//                        
//                    }
//                    // Not enough data to auto generate an entry
                    else {
                        entries.append(JournalEntry())
                        dismiss()
                    }
                }
        }
    }
}

struct FileChooser: View {
    @Environment(\.isEnabled) var enabled
    let title: String
    let allowedContentTypes: [UTType]
    @State var showFileImporter = false
    @State var dragHover = false
    @Binding var resultURL: URL?
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading) {
                    Section {
                        if let resultURL = resultURL {
                            Text("File: " + resultURL.lastPathComponent)
                        } else {
                            Text("Drag or Browse for File")
                                .font(.italic(.body)())
                        }
                    } header: {
                        HStack {
                            Text(title)
                                .font(.title)
                            Button {
                                showFileImporter = true
                            } label: {
                                Image(systemName: "folder.badge.plus")
                            }
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
            if dragHover {
                Image(systemName: "square.and.arrow.down.on.square")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.primary)
            }
        }
        .frame(minHeight: 100)
        .opacity(enabled ? 1 : 0.5)
        .padding()
        .border(.selection)
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: allowedContentTypes) { result in
            resultURL = try? result.get()
        }
        .onDrop(of: [.fileURL], isTargeted: $dragHover) { providers in
            if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
                let _ = provider.loadObject(ofClass: URL.self) { object, error in
                    if let url = object {
                        resultURL = url
                    }
                }
                return true
            }
            return false
        }
    }
}

struct MultipleFileChooser: View {
    @Environment(\.isEnabled) var enabled
    let title: String
    let allowedContentTypes: [UTType]
    @State var showFileImporter = false
    @Binding var resultURLs: Set<URL>?
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Section {
                    if let resultURL = resultURLs {
                        Text("\(resultURL.count) Files Selected")
                    } else {
                        Text("Browse for Files")
                            .font(.italic(.body)())
                    }
                } header: {
                    HStack {
                        Text(title)
                            .font(.title)
                        Button {
                            showFileImporter = true
                        } label: {
                            Image(systemName: "folder.badge.plus")
                        }
                    }
                }
                Spacer()
            }
            Spacer()
        }
        .frame(minHeight: 100)
        .opacity(enabled ? 1 : 0.5)
        .padding()
        .border(.selection)
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: allowedContentTypes, allowsMultipleSelection: true) { result in
            if resultURLs != nil, let results = try? result.get() {
                resultURLs!.formUnion(results)
            } else {
                resultURLs = Set((try? result.get()) ?? [])
            }
            
        }
    }
}
