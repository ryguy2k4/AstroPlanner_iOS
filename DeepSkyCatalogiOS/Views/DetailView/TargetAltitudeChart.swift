//
//  TargetAltitudeChart.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 12/27/23.
//

import SwiftUI
import SwiftData
import Charts
import DeepSkyCore

/**
 A chart that plots altitude vs time for a target
 */
struct TargetAltitudeChart: View {
    @Query var targetSettings: [TargetSettings]
    @EnvironmentObject var store: HomeViewModel
    var target: DeepSkyTarget
    let showLimitingAlt: Bool
    var body: some View {
        // Graph
        let hours = store.date.getEveryHour()
        Chart {
            ForEach(hours, id: \.self) { hour in
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
            RectangleMark(xStart: .value("", store.date.addingTimeInterval(43_200)), xEnd: .value("", store.viewingInterval.start))
                .foregroundStyle(.tertiary.opacity(1))
            RectangleMark(xStart: .value("", store.viewingInterval.end), xEnd: .value("", store.date.tomorrow().addingTimeInterval(43_200)))
                .foregroundStyle(.tertiary.opacity(1))
        }
        .chartXAxis {
            AxisMarks(position: .bottom, values: [Calendar.current.date(byAdding: .hour, value: 3, to: hours[0])!,
                                                  Calendar.current.date(byAdding: .hour, value: 9, to: hours[0])!,
                                                  Calendar.current.date(byAdding: .hour, value: 15, to: hours[0])!,
                                                  Calendar.current.date(byAdding: .hour, value: 21, to: hours[0])!]
            ) {
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
            Text("Visibility Score: \((target.getVisibilityScore(at: store.location, viewingInterval: store.viewingInterval, limitingAlt: showLimitingAlt ? (targetSettings.first?.limitingAltitude ?? 0) : 0)).percent())")
                .foregroundColor(.secondary)
                .font(.headline)
        }
        .chartYAxisLabel(position: .bottom, alignment: .bottomLeading) {
            if (targetSettings.first?.limitingAltitude ?? 0) != 0 {
                Text("Tap to toggle limiting altitude")
            }
        }
        .padding(.horizontal)
        .frame(minHeight: 150)
    }
}

