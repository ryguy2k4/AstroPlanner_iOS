//
//  DetailView.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/7/22.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    @EnvironmentObject var store: HomeViewModel
    @Environment(\.modelContext) var context
    
    @Query var targetSettings: [TargetSettings]
    
    @State var showCoordinateDecimalFormat: Bool = false
    @State var showLimitingAlt: Bool = true
    
    let target: DeepSkyTarget
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                // Target Image
                // If the target has a local image, display it
                if let image = target.image, let filename = image.filename {
                    VStack {
                        NavigationLink {
                            ImageViewer(image: image, filename: filename)
                        } label: {
                            Image(filename)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(12)
                        }
                        Text(image.credit)
                            .fontWeight(.light)
                            .lineLimit(2)
                            .font(.caption)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                }
                // If the target has an APOD images associated with it, display a link to it
                else if let image = target.image, let url = image.url {
                    Link("View Image on APOD", destination: url)
                        .padding(.bottom)
                }
                
                // Target Facts
                VStack(spacing: 8) {
                    VStack {
                        Text(target.type.rawValue + " in " + target.constellation.rawValue)
                            .font(.subheadline)
                            .fontWeight(.light)
                            .lineLimit(1)
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            FactLabel(text: showCoordinateDecimalFormat ? (target.ra / 15).formatDecimal() + "h" : target.ra.formatHMS(), image: "r.square.fill")
                            FactLabel(text: showCoordinateDecimalFormat ? target.dec.formatDecimal() + "°" : target.dec.formatDMS(), image: "d.square.fill")
                        }
                        .onTapGesture {
                            showCoordinateDecimalFormat.toggle()
                        }
                        Divider()
                        VStack(alignment: .leading) {
                            FactLabel(text: " Mag \(target.apparentMag == nil ? "N/A" : String(target.apparentMag!))", image: "sun.min.fill")
                            FactLabel(text:" \(target.arcLength)' x \(target.arcWidth)'", image: "arrow.up.left.and.arrow.down.right")
                        }
                    }
                }
                
                // Target Graphs
                VStack {
                    TargetAltitudeChart(target: target, showLimitingAlt: showLimitingAlt)
                        .onTapGesture {
                            showLimitingAlt.toggle()
                        }
                    TargetSchedule(target: target, showLimitingAlt: showLimitingAlt)
                    TargetSeasonScoreChart(target: target)
                }
                
                // Target Description
                VStack(alignment: .leading, spacing: 10) {
                    Text(target.description)
                    if let link = target.wikipediaURL {
                        Link(destination: link) {
                            Label("Wikipedia", systemImage: "arrow.up.forward.square")
                        }
                    }
                }.padding()
                
                // List Sub Targets
                if !target.subTargets.isEmpty {
                    Text("Sub Targets")
                        .fontWeight(.semibold)
                    ScrollView(.horizontal) {
                        HStack {
                            let targets = target.subTargets.map { id in
                                DeepSkyTargetList.allTargets.first(where: {$0.id == id})!
                            }
                            ForEach(targets) { target in
                                NavigationLink {
                                    DetailView(target: target)
                                } label: {
                                    VStack(alignment: .center) {
                                        Image(target.image?.filename ?? "\(target.type)")
                                            .resizable()
                                            .scaledToFit()
                                        Text(target.defaultName)
                                    }
                                    .frame(maxWidth: 150, maxHeight: 200)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .toolbar {
            // Ellipsis menu in top right
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    ShareLink("Share", item: generateShareString())
                    Button("Hide Target") {
                        let newHiddenTarget = HiddenTarget(id: target.id, origin: targetSettings.first!)
                        context.insert(newHiddenTarget)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
            // Display Target Name in top middle of the screen
            ToolbarItem(placement: .principal) {
                Label(target.defaultName, image: "gear")
                    .labelStyle(.titleOnly)
                    .font(.headline)
            }
        }
    }
    
    /**
     This returns a string that describes the target on the day and location selected that is meant to be exported from the app and sent elsewhere, i.e. by text message.
     */
    func generateShareString() -> String {
        let visibilityScore = target.getVisibilityScore(at: store.location, viewingInterval: store.viewingInterval, limitingAlt: targetSettings.first?.limitingAltitude ?? 0)
        let seasonScore = target.getSeasonScore(at: store.location, on: store.date, sunData: store.sunData)
        let targetInterval = target.getNextInterval(location: store.location, date: store.date, limitingAlt: showLimitingAlt ? targetSettings.first?.limitingAltitude ?? 0 : 0)
        let scheduleString: String = {
            switch targetInterval.interval {
            case .always:
                return "Target is always in the sky; Meridian crossing at \(DateFormatter.shortTimeOnly(timezone: store.location.timezone).string(from: targetInterval.culmination))"
            case .never:
                return "Target is never in the sky; Meridian crossing at \(DateFormatter.shortTimeOnly(timezone: store.location.timezone).string(from: targetInterval.culmination))"
            case .sometimes(let interval):
                return "Target rises at \(DateFormatter.shortTimeOnly(timezone: store.location.timezone).string(from: interval.start)) and sets at \(DateFormatter.shortTimeOnly(timezone: store.location.timezone).string(from: interval.end)); Meridian crossing is at \(DateFormatter.shortTimeOnly(timezone: store.location.timezone).string(from: targetInterval.culmination))"
            }
        }()
        return "\(target.defaultName)\n\(target.type.rawValue) in \(target.constellation.rawValue) \n \(target.wikipediaURL?.absoluteString ?? "")\n\nNight of \(DateFormatter.longDateOnly(timezone: store.location.timezone).string(from: store.date)) | \(store.location.name)\nVisibility Score: \(visibilityScore.percent())\nSeason Score: \(seasonScore.percent())\n\(scheduleString)"
    }
    
    /**
     A label that displays a target fact
     */
    private struct FactLabel: View {
        var text: String
        var image: String
        var body: some View {
            Label(text, systemImage: image)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}


