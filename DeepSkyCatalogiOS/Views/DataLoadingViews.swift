//
//  DataLoadingViews.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 3/26/23.
//

import SwiftUI

struct DailyReportLoadingView: View {
    @EnvironmentObject var store: HomeViewModel
    @FetchRequest(sortDescriptors: []) var reportSettings: FetchedResults<ReportSettings>
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
            // in case it causes a hold up, and display a loading screen
            .task {
                store.sunData = Sun.sol.getNextInterval(location: store.location, date: store.date)
                // If its in the morning hours of the next day, still show the info for the previous day (current night)
                if Sun.sol.getAltitude(location: store.location, time: .now) < -18 && .now > store.sunData.solarMidnight {
                    store.date = store.date.yesterday()
                }
                if reportSettings.first!.darknessThreshold == Int16(2) {
                    store.viewingInterval = store.sunData.CTInterval
                } else if reportSettings.first!.darknessThreshold == Int16(1) {
                    store.viewingInterval = store.sunData.NTInterval
                } else {
                    store.viewingInterval = store.sunData.ATInterval
                }
            }
        }
    }
}

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

//struct DailyReportLoadingFailedView: View {
//    @EnvironmentObject var store: HomeViewModel
//    @EnvironmentObject var networkManager: NetworkManager
//    @Binding var internet: Bool
//    var body: some View {
//        NavigationStack {
//            VStack {
//                Text("Daily Report Unavailable Offline")
//                    .fontWeight(.bold)
//                    .padding(.vertical)
//                Button("Retry") {
//                    internet = true
//                    Task {
//                        do {
//                            let data = try await networkManager.updateSunData(at: store.location, on: store.date)
//                            // merge the new data, overwriting if necessary
//                            networkManager.sun.merge(data) { _, new in new }
//                        } catch {
//                            internet = false
//                        }
//                    }
//                }
//                Spacer()
//            }
//        }
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Image(systemName: "wifi.exclamationmark")
//                    .foregroundColor(.red)
//            }
//        }
//    }
//}
