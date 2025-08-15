//
//  TargetSeasonScoreChart.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 12/27/23.
//

import SwiftUI
import Charts
import DeepSkyCore

/**
 A chart that plots altitude vs time for a target
 */
struct TargetSeasonScoreChart: View {
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
        .frame(minHeight: 150)
    }
}
