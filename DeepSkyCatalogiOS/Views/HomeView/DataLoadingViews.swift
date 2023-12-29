//
//  DataLoadingViews.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 3/26/23.
//

import SwiftUI
import SwiftData

/**
 This view is displayed when sunData needs to be calculated
 It will display a spinning progress icon and start calculating the sunData on a **background thread**
 */
struct DailyReportLoadingView: View {
    @EnvironmentObject var store: HomeViewModel
    @Query var reportSettings: [ReportSettings]
    var body: some View {
        NavigationStack {
            VStack {
                ProgressView("Calculating Sun Data")
                    .padding(.top, 50)
                Spacer()
            }
            .toolbar {
                ToolbarLogo()
            }
            // Calculate sunData on a background thread
            .task {
                store.sunData = Sun.sol.getNextInterval(location: store.location, date: store.date)
                // If its in the morning hours of the next day, still show the info for the previous day (current night)
                if Sun.sol.getAltitude(location: store.location, time: .now) < -18 && .now > store.sunData.solarMidnight {
                    store.date = store.date.yesterday()
                }
                if reportSettings.first!.darknessThreshold == 2 {
                    store.viewingInterval = store.sunData.CTInterval
                } else if reportSettings.first!.darknessThreshold == 1 {
                    store.viewingInterval = store.sunData.NTInterval
                } else {
                    store.viewingInterval = store.sunData.ATInterval
                }
            }
        }
    }
}

/**
 This view is simply a complement ot DailyReportLoadingView
 */
struct CatalogLoadingView: View {
    var body: some View {
        VStack {
            ProgressView("Calculating Sun Data")
                .padding(.top, 50)
            Spacer()
        }
        .toolbar {
            ToolbarLogo()
        }
    }
}
