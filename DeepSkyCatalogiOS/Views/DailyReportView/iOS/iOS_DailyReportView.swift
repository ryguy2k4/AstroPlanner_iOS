//
//  iOS_DailyReportView.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 1/10/24.
//

import SwiftUI

struct iOS_DailyReportView: View {
    @State var topTenTab: TargetTab = .nebulae
    let report: DailyReport
    let reportHeader: String

    var body: some View {
        NavigationStack {
            VStack {
                Text(reportHeader)
                    .font(.subheadline)
                    .lineLimit(1)
                    .padding(5)
                TopFiveView(report: report)
                TopTenTabView(report: report, tabSelection: $topTenTab)
                    .onAppear() {
                        if report.topTenNebulae.isEmpty { topTenTab = .galaxies }
                        else if report.topTenNebulae.isEmpty && report.topTenGalaxies.isEmpty { topTenTab = .starClusters }
                    }
            }
            .navigationDestination(for: DeepSkyTarget.self) { target in
                DetailView(target: target)
            }
        }
    }
}
