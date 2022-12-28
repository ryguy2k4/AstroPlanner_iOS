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
                    Image(target.image[0])
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(12)
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
                    VStack() {
                        TargetAltitudeChart(target: target)
                            .padding()
                        HStack {
                            if let eventOrder = getNextOrder(for: target, sunData: data.sun) {
                                if eventOrder.count == 3 {
                                    EventLabel(text: eventOrder[0].date.formatted(format: "h:mm a \n MM/dd"), image: eventOrder[0].event.rawValue)
                                    EventLabel(text: eventOrder[1].date.formatted(format: "h:mm a \n MM/dd"), image: eventOrder[1].event.rawValue)
                                    EventLabel(text: eventOrder[2].date.formatted(format: "h:mm a \n MM/dd"), image: eventOrder[2].event.rawValue)
                                } else {
                                    Text("\(eventOrder[0].error!.rawValue)")
                                }
                            } else {
                                Text("Error Getting Events")
                            }
                        }
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
    
    func getNextOrder(for target: DeepSkyTarget, sunData: SunData) -> [EventInfo]? {
        do {
            let array = [EventInfo(event: .rise, date: try target.getNextInterval(at: location, on: date, sunData: sunData).start), EventInfo(event: .meridian, date: target.getNextMeridian(at: location, on: date, sunData: sunData)), EventInfo(event: .set, date: try target.getNextInterval(at: location, on: date, sunData: sunData).end)]
            return array.sorted(by: {$0.date < $1.date})
        } catch TargetCalculationError.neverRises {
            return [EventInfo(event: .rise, date: Date(), error: TargetCalculationError.neverRises)]
        } catch TargetCalculationError.neverSets {
            return [EventInfo(event: .set, date: Date(), error: TargetCalculationError.neverSets)]
        } catch {
            print("Unexpected Error: \(error)")
            return nil
        }
    }
}

//struct TargetDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView(target: DeepSkyTargetList.allTargets[0])
//    }
//}

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

struct EventInfo {
    enum Event: String {
        case rise = "sunrise"
        case meridian = "arrow.right.and.line.vertical.and.arrow.left"
        case set = "sunset"
    }
    let event: Event
    let date: Date
    let error: TargetCalculationError?
    init(event: Event, date: Date, error: TargetCalculationError? = nil) {
        self.event = event
        self.date = date
        self.error = error
    }
}
