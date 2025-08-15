//
//  iPad_DailyReportView.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 1/10/24.
//

import SwiftUI
import DeepSkyCore

struct iPad_DailyReportView: View {
    let report: DailyReport
    let reportHeader: String
    var body: some View {
        VStack {
            iPad_TopFiveView(report: report)
            Divider()
            HStack {
                iPad_TopTenListView(reportList: report.topTenNebulae, targetTab: .nebulae)
                iPad_TopTenListView(reportList: report.topTenGalaxies, targetTab: .galaxies)
                iPad_TopTenListView(reportList: report.topTenStarClusters, targetTab: .starClusters)
            }
        }
        .navigationTitle(reportHeader)
        .navigationBarTitleDisplayMode(.inline)

    }
}
