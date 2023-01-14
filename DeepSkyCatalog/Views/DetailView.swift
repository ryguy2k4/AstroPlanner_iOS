//
//  DetailView.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/7/22.
//

import SwiftUI
import Charts

struct DetailView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var location: SavedLocation
    @EnvironmentObject var reportSettings: ReportSettings
    @Environment(\.date) var date
    var target: DeepSkyTarget
    var body: some View {
        if let data = networkManager.data[.init(date: date, location: location)] {
            ScrollView {
                VStack(spacing: 10) {
                    
                    // Target Image
                    VStack {
                        NavigationLink(destination: ImageViewer(image: target.image.source.fileName)) {
                            Image(target.image.source.fileName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(12)
                        }
                        if let credit = target.image.copyright {
                            Text("Image Copyright: " + credit)
                                .fontWeight(.light)
                                .lineLimit(1)
                                .font(.caption)
                        }
                    }
                    
                    // Target Facts
                    VStack {
                        VStack {
                            Text(target.name[0])
                                .font(.title2)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            Text(target.type[0].rawValue)
                                .font(.subheadline)
                                .fontWeight(.light)
                                .lineLimit(1)
                        }
                        HStack {
                            VStack(alignment: .leading) {
                                FactLabel(text: target.constellation.rawValue, image: "star")
                                FactLabel(text: " RA: \(target.ra.formatted(.number.precision(.significantDigits(0...5))))", image: "arrow.left.arrow.right")
                                FactLabel(text: "DEC: \(target.dec.formatted(.number.precision(.significantDigits(0...5))))", image: "arrow.up.arrow.down")
                                FactLabel(text: " Mag \(target.apparentMag)", image: "sun.min.fill")
                                FactLabel(text:" \(target.arcLength)' x \(target.arcWidth)'", image: "arrow.up.left.and.arrow.down.right")
                            }
                            VStack {
                                Text("Visibility Score: \((target.getVisibilityScore(at: location, on: date, sunData: data.sun, limitingAlt: reportSettings.limitingAltitude)).percent())")
                                    .foregroundColor(.secondary)
                                Text("Meridian Score: \((target.getMeridianScore(at: location, on: date, sunData: data.sun)).percent())")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Target Graph
                    VStack() {
                        TargetAltitudeChart(target: target)
                            .padding()
                        if let interval = try? target.getNextInterval(at: location, on: date, sunData: data.sun) {
                            HStack {
                                EventLabel(date: interval.start, image: "sunrise")
                                EventLabel(date: target.getNextMeridian(at: location, on: date, sunData: data.sun), image: "arrow.right.and.line.vertical.and.arrow.left")
                                EventLabel(date: interval.end, image: "sunset")
                            }
                        } else {
                            VStack {
                                if target.getAltitude(location: location, time: date) > reportSettings.limitingAltitude {
                                    Text("Target Never Sets")
                                } else {
                                    Text("Target Never Rises")
                                }
                                EventLabel(date: target.getNextMeridian(at: location, on: date, sunData: data.sun), image: "arrow.right.and.line.vertical.and.arrow.left")
                            }
                        }
                    }
                    
                    // Target Description
                    VStack(alignment: .leading, spacing: 10) {
                        Text(target.description)
                        Link(destination: target.descriptionURL) {
                            Label("Wikipedia", systemImage: "arrow.up.forward.square")
                        }
                    }.padding()
                }
            }
        } else {
            ProgressView()
        }
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

//struct TargetDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView(target: DeepSkyTargetList.allTargets[0])
//    }
//}
