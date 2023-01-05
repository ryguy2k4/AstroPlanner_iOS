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
    @Environment(\.date) var date
    var target: DeepSkyTarget
    var body: some View {
        if let data = networkManager.data[.init(date: date, location: location)] {
            ScrollView {
                VStack(spacing: 10) {
                    VStack {
                        Image(target.image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                        if let credit = target.imageCopyright {
                            Text("Image Copyright: " + credit)
                                .fontWeight(.light)
                                .lineLimit(1)
                                .font(.caption)
                        }
                    }
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
                            Text("Visibility Score: \((target.getVisibilityScore(at: location, on: date, sunData: data.sun)).percent())")
                                .foregroundColor(.secondary)
                            Text("Meridian Score: \((target.getMeridianScore(at: location, on: date, sunData: data.sun)).percent())")
                                .foregroundColor(.secondary)
                        }
                    }
                    VStack() {
                        TargetAltitudeChart(target: target)
                            .padding()
                        if let interval = try? target.getNextInterval(at: location, on: date, sunData: data.sun) {
                            HStack {
                                EventLabel(text: interval.start.formatted(format: "h:mm a \n MM/dd"), image: "sunrise")
                                EventLabel(text: target.getNextMeridian(at: location, on: date, sunData: data.sun).formatted(format: "h:mm a \n MM/dd"), image: "arrow.right.and.line.vertical.and.arrow.left")
                                EventLabel(text: interval.end.formatted(format: "h:mm a \n MM/dd"), image: "sunset")
                            }
                        } else {
                            VStack {
                                Text("Target Never Rises or Target Never Sets")
                                EventLabel(text: target.getNextMeridian(at: location, on: date, sunData: data.sun).formatted(format: "h:mm a \n MM/dd"), image: "arrow.right.and.line.vertical.and.arrow.left")
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        Text(target.description)
                        Link(destination: target.descriptionURL) {
                            Label("Wikipedia", systemImage: "arrow.up.forward.square")
                        }
                        
                    }
                    .font(.body)
                    .padding()
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
                LineMark(x: .value("Hour", hour, unit: .hour), y: .value("Altitude", target.getAltitude(at: location, at: hour)))
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

struct FactLabel: View {
    var text: String
    var image: String
    var body: some View {
        Label(text, systemImage: image)
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
}

struct EventLabel: View {
    var text: String
    var image: String
    var body: some View {
        Label(text, systemImage: image)
            .font(.body)
            .frame(width: 110, height: 60)
            
    }
}

//struct TargetDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView(target: DeepSkyTargetList.allTargets[0])
//    }
//}
