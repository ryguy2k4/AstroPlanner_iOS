//
//  DetailView.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/7/22.
//

import SwiftUI
import Charts

struct DetailView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var location: SavedLocation
    @EnvironmentObject var targetSettings: TargetSettings
    @Environment(\.date) var date
    var target: DeepSkyTarget
    var body: some View {
        let data = networkManager.data[.init(date: date, location: location)]
            ScrollView {
                VStack(spacing: 10) {
                    
                    // Target Image
                    if let image = target.image {
                        VStack {
                            NavigationLink(destination: ImageViewer(image: image.source.fileName)) {
                                Image(image.source.fileName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(12)
                            }
                            if let credit = image.copyright {
                                Text("Image Copyright: " + credit)
                                    .fontWeight(.light)
                                    .lineLimit(2)
                                    .font(.caption)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Target Facts
                    VStack {
                        VStack {
                            Text(target.name?[0] ?? target.defaultName)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            Text(target.type.rawValue)
                                .font(.subheadline)
                                .fontWeight(.light)
                                .lineLimit(1)
                        }
                        HStack {
                            VStack(alignment: .leading) {
                                FactLabel(text: target.constellation.rawValue, image: "star")
                                FactLabel(text: " RA: \(target.ra.formatted(.number.precision(.significantDigits(0...5))))", image: "arrow.left.arrow.right")
                                FactLabel(text: "DEC: \(target.dec.formatted(.number.precision(.significantDigits(0...5))))", image: "arrow.up.arrow.down")
                                FactLabel(text: " Mag \(target.apparentMag == nil ? "N/A" : String(target.apparentMag!))", image: "sun.min.fill")
                                FactLabel(text:" \(target.arcLength)' x \(target.arcWidth)'", image: "arrow.up.left.and.arrow.down.right")
                            }
                            if let sun = data?.sun {
                                VStack {
                                    Text("Visibility Score: \((target.getVisibilityScore(at: location, on: date, sunData: sun, limitingAlt: targetSettings.limitingAltitude)).percent())")
                                        .foregroundColor(.secondary)
                                    Text("Meridian Score: \((target.getMeridianScore(at: location, on: date, sunData: sun)).percent())")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    // Target Graph
                    TargetSchedule(target: target)
                    
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
                                            Image(target.image?.source.fileName ?? "\(target.type)")
                                                .resizable()
                                                .scaledToFit()
                                            Text(target.name?.first ?? target.defaultName)
                                        }
                                        .frame(maxWidth: 150, maxHeight: 200)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Hide Target") {
                            let newHiddenTarget = HiddenTarget(context: context)
                            newHiddenTarget.id = target.id
                            targetSettings.addToHiddenTargets(newHiddenTarget)
                            PersistenceManager.shared.saveData(context: context)
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }

                }
            }
        }.environment(\.data, data)
    }
}

/**
 A chart that plots altitude vs time for a target
 */
struct TargetAltitudeChart: View {
    @EnvironmentObject var location: SavedLocation
    @Environment(\.date) var date
    var target: DeepSkyTarget
    var body: some View {
        Chart {
            ForEach(date.getEveryHour(), id: \.self) { hour in
                LineMark(x: .value("Hour", hour, unit: .hour), y: .value("Altitude", target.getAltitude(location: location, time: hour)))
                    .interpolationMethod(.catmullRom)
            }
            RuleMark(y: .value("Axis", 0))
                .foregroundStyle(.gray)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: 6)) {
                AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
                AxisGridLine()
            }
        }
        .chartYAxisLabel("Altitude (°)")
    }
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

/**
 A label that displays a target event
 */
private struct EventLabel: View {
    var date: Date
    var image: String
    var body: some View {
        VStack(spacing: 3) {
            Label(date.formatted(date: .omitted, time: .shortened) , systemImage: image)
            Text(date.formatted(date: .numeric, time: .omitted))
                .minimumScaleFactor(0.8)
        }
        .frame(width: 110, height: 60)
            
    }
}

struct TargetSchedule: View {
    @Environment(\.data) var data
    @Environment(\.date) var date
    @EnvironmentObject var location: SavedLocation
    let target: DeepSkyTarget
    var body: some View {
        if let sun = data?.sun {
            VStack() {
                TargetAltitudeChart(target: target)
                    .padding()
                if let interval = try? target.getNextInterval(at: location, on: date, sunData: sun) {
                    HStack {
                        EventLabel(date: interval.start, image: "sunrise")
                        EventLabel(date: target.getNextMeridian(at: location, on: date, sunData: sun), image: "arrow.right.and.line.vertical.and.arrow.left")
                        EventLabel(date: interval.end, image: "sunset")
                    }
                } else {
                    VStack {
                        if target.getAltitude(location: location, time: date) > 0 {
                            Text("Target Never Sets")
                        } else {
                            Text("Target Never Rises")
                        }
                        EventLabel(date: target.getNextMeridian(at: location, on: date, sunData: sun), image: "arrow.right.and.line.vertical.and.arrow.left")
                    }
                }
            }
        }
    }
}
