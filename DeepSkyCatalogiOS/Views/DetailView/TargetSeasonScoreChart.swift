//
//  TargetSeasonScoreChart.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 12/27/23.
//

import SwiftUI
import Charts
import SwiftData
import DeepSkyCore

/**
 A chart that plots altitude vs time for a target
 */
struct TargetSeasonScoreChart: View {
    @EnvironmentObject var store: HomeViewModel
    @Query var reportSettings: [ReportSettings]
    var target: DeepSkyTarget
    var body: some View {
        
        // for showing adjusted season score based on viewing interval
        let nightInterval = {
            if reportSettings.first!.darknessThreshold == 2 {
                return store.sunData.CTInterval
            } else if reportSettings.first!.darknessThreshold == 1 {
                return store.sunData.NTInterval
            } else {
                return store.sunData.ATInterval
            }
        }()
        let customViewingInterval = store.viewingInterval != nightInterval
        
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
            let score = target.getSeasonScore(at: store.location, on: store.date, sunData: store.sunData)
            let relativeScore = target.getSeasonScore(at: store.location, viewingInterval: store.viewingInterval, sunData: store.sunData)
            
            if customViewingInterval {
                Text("Season Score: \(score.percent()) (*\(relativeScore.percent()))")
                    .foregroundColor(.secondary)
                    .font(.headline)
            } else {
                Text("Season Score: \(score.percent())")
                    .foregroundColor(.secondary)
                    .font(.headline)
            }
        }
        .padding(.horizontal)
        .frame(minHeight: 150)
        Text("*Adjusted for viewing interval.")
            .font(.footnote)
    }
}
