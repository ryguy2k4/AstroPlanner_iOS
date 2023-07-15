//
//  Mac_DetailView.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 7/13/23.
//

import SwiftUI
import Charts

struct Mac_DetailView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var networkManager: NetworkManager
    @FetchRequest(sortDescriptors: []) var targetSettings: FetchedResults<TargetSettings>
    @EnvironmentObject var store: HomeViewModel
    
    @State var showCoordinateDecimalFormat: Bool = false
    @State var showLimitingAlt: Bool = true
    let target: DeepSkyTarget
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                // Target Image
                if let image = target.image, let filename = image.source.fileName {
                    VStack {
                        Image(filename)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                        Text(image.credit)
                            .fontWeight(.light)
                            .lineLimit(2)
                            .font(.caption)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                } else if let image = target.image, let url = image.source.url {
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
                            FactLabel(text: showCoordinateDecimalFormat ? (target.ra / 15).formatted(.number.precision(.significantDigits(0...5))) + "h" : target.ra.formatHMS(), image: "r.square.fill")
                            FactLabel(text: showCoordinateDecimalFormat ? target.dec.formatted(.number.precision(.significantDigits(0...5))) + "°" : target.dec.formatDMS(), image: "d.square.fill")
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
                                    Mac_DetailView(target: target)
                                } label: {
                                    VStack(alignment: .center) {
                                        Image(target.image?.source.fileName ?? "\(target.type)")
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
    }
}

/**
 A chart that plots altitude vs time for a target
 */
fileprivate struct TargetAltitudeChart: View {
    @FetchRequest(sortDescriptors: []) var targetSettings: FetchedResults<TargetSettings>
    @EnvironmentObject var store: HomeViewModel
    var target: DeepSkyTarget
    let showLimitingAlt: Bool
    var body: some View {
        // Graph
        Chart {
            ForEach(store.date.getEveryHour(), id: \.self) { hour in
                LineMark(x: .value("Hour", hour, unit: .minute), y: .value("Altitude", target.getAltitude(location: store.location, time: hour)))
                    .interpolationMethod(.catmullRom)
            }
            RuleMark(y: .value("Axis", showLimitingAlt ? (targetSettings.first?.limitingAltitude ?? 0) : 0))
                .foregroundStyle(.gray)
            if Date.now > store.date.localNoon(timezone: store.location.timezone) && Date.now < store.date.localNoon(timezone: store.location.timezone).tomorrow() {
                RuleMark(x: .value("Now", Date.now))
                    .lineStyle(.init(dash: [5]))
                    .foregroundStyle(.red)
            }
            RectangleMark(xStart: .value("", store.date.startOfLocalDay(timezone: store.location.timezone).addingTimeInterval(43_200)), xEnd: .value("", store.viewingInterval.start))
                .foregroundStyle(.tertiary.opacity(1))
            RectangleMark(xStart: .value("", store.viewingInterval.end), xEnd: .value("", store.date.tomorrow().addingTimeInterval(43_200)))
                .foregroundStyle(.tertiary.opacity(1))
        }
        .chartXAxis {
            AxisMarks(position: .bottom, values: .stride(by: .hour, count: 6)) {
                let format: Date.FormatStyle = {
                    var format: Date.FormatStyle = .dateTime.hour(.defaultDigits(amPM: .abbreviated))
                    format.timeZone = store.location.timezone
                    return format
                }()
                AxisValueLabel(format: format)
                AxisGridLine()
            }
        }
        .chartYAxisLabel(position: .top, alignment: .topTrailing) {
            Text("Altitude (°)")
        }
        .chartYAxisLabel(position: .top, alignment: .center) {
            Text("Visibility Score: \((target.getVisibilityScore(at: store.location, viewingInterval: store.viewingInterval, sunData: store.sunData, limitingAlt: showLimitingAlt ? (targetSettings.first?.limitingAltitude ?? 0) : 0)).percent())")
                .foregroundColor(.secondary)
                .font(.headline)
        }
        .chartYAxisLabel(position: .bottom, alignment: .bottomLeading) {
            if (targetSettings.first?.limitingAltitude ?? 0) != 0 {
                Text("Tap to toggle limiting altitude")
            }
        }
        .padding(.horizontal)
    }
}

fileprivate struct TargetSchedule : View {
    @FetchRequest(sortDescriptors: []) var targetSettings: FetchedResults<TargetSettings>
    @EnvironmentObject var store: HomeViewModel
    let target: DeepSkyTarget
    let showLimitingAlt: Bool
    var body: some View {
        let targetInterval = target.getNextInterval(location: store.location, date: store.date, limitingAlt: showLimitingAlt ? targetSettings.first?.limitingAltitude ?? 0 : 0)
        HStack {
            switch targetInterval.interval {
            case .never:
                EventLabel(date: target.getNextInterval(location: store.location, date: store.date).culmination, image: "arrow.right.and.line.vertical.and.arrow.left")
            case .always:
                EventLabel(date: target.getNextInterval(location: store.location, date: store.date).culmination, image: "arrow.right.and.line.vertical.and.arrow.left")
            case .sometimes(let interval):
                EventLabel(date: interval.start, image: "sunrise")
                EventLabel(date: target.getNextInterval(location: store.location, date: store.date).culmination, image: "arrow.right.and.line.vertical.and.arrow.left")
                EventLabel(date: interval.end, image: "sunset")
            }
        }
    }
}

/**
 A chart that plots altitude vs time for a target
 */
fileprivate struct TargetSeasonScoreChart: View {
    @EnvironmentObject var store: HomeViewModel
    var target: DeepSkyTarget
    var body: some View {
        // Graph
        Chart {
            ForEach(store.date.getEveryMonth(), id: \.self) { month in
                LineMark(x: .value("Month", month, unit: .day), y: .value("Score", target.getApproxSeasonScore(at: store.location, on: month)*100))
                    .interpolationMethod(.catmullRom)
            }
            RuleMark(y: .value("Axis", 0))
                .foregroundStyle(.gray)
            RuleMark(x: .value("Now", store.date))
                .lineStyle(.init(dash: [5]))
                .foregroundStyle(.red)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month, count: 1)) {
                AxisValueLabel(format: .dateTime.month(.narrow))
                AxisGridLine()
            }
        }
        .chartYAxisLabel(position: .top, alignment: .topTrailing) {
            Text("Score")
        }
        .chartYAxisLabel(position: .top, alignment: .center) {
            Text("Season Score: \((target.getSeasonScore(at: store.location, on: store.date, sunData: store.sunData)).percent())")
                .foregroundColor(.secondary)
                .font(.headline)
        }
        .padding(.horizontal)
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
    @EnvironmentObject var store: HomeViewModel
    var date: Date
    var image: String
    var body: some View {
        VStack(spacing: 3) {
            Label(DateFormatter.shortTimeOnly(timezone: store.location.timezone).string(from: date) , systemImage: image)
            Text(DateFormatter.shortDateOnly(timezone: store.location.timezone).string(from: date))
                .minimumScaleFactor(0.8)
        }
        .frame(width: 110, height: 60)
            
    }
}

//struct Mac_DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        Mac_DetailView()
//    }
//}
