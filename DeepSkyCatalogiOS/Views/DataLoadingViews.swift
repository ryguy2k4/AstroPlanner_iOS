//
//  DataLoadingViews.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 3/26/23.
//

import SwiftUI

struct DailyReportLoadingView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var store: HomeViewModel
    @Binding var internet: Bool
    var body: some View {
        NavigationStack {
            VStack {
                ProgressView()
                    .padding(.top)
                Text("Fetching Sun/Moon Data...")
                    .fontWeight(.bold)
                Spacer()
            }
            .toolbar {
                ToolbarLogo()
            }
            .task {
                do {
                    let data = try await networkManager.updateSunData(at: store.location, on: store.date)
                    // merge the new data, overwriting if necessary
                    networkManager.sun.merge(data) { _, new in new }
                    store.sunData = networkManager.sun[NetworkManager.DataKey(date: store.date, location: store.location)] ?? SunData()
                    // here insert check for requesting data between midnight and night end should get info for the previous day still
                    store.viewingInterval = store.sunData.ATInterval
                } catch {
                    internet = false
                }
            }
        }
    }
}

struct DailyReportLoadingFailedView: View {
    @EnvironmentObject var store: HomeViewModel
    @EnvironmentObject var networkManager: NetworkManager
    @Binding var internet: Bool
    var body: some View {
        NavigationStack {
            VStack {
                Text("Daily Report Unavailable Offline")
                    .fontWeight(.bold)
                    .padding(.vertical)
                Button("Retry") {
                    internet = true
                    Task {
                        do {
                            let data = try await networkManager.updateSunData(at: store.location, on: store.date)
                            // merge the new data, overwriting if necessary
                            networkManager.sun.merge(data) { _, new in new }
                        } catch {
                            internet = false
                        }
                    }
                }
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Image(systemName: "wifi.exclamationmark")
                    .foregroundColor(.red)
            }
        }
    }
}
