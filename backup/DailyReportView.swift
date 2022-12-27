//
//  DailyReportView.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/25/22.
//

import SwiftUI

struct DailyReportView: View {
    @EnvironmentObject var appConfig: AppConfig
    @ObservedObject var viewModel = DailyReportViewModel()
    
    var body: some View {
        VStack(spacing: 100) {
            Text("Daily Report for the Night of \n\(appConfig.date.formatted(with: "MMMM d, y"))")
                .multilineTextAlignment(.center)
                .font(.title)
                .underline()
            Text("The moon is \(appConfig.moon?.illuminated ?? "n/a") illuminated tonight")
            List(viewModel.targets, id: \.id) { target in
                Text("\(target.name.first!)")
            }
        }
        .onAppear() {
            viewModel.getReport(with: appConfig)
        }
    }
}

struct DailyReportView_Previews: PreviewProvider {
    static var previews: some View {
        DailyReportView()
            .environmentObject(ConfigTest.appConfig)
    }
}
