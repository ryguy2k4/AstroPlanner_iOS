//
//  DataLoadingViews.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 3/26/23.
//

import SwiftUI

struct DailyReportLoadingView: View {
    @Environment(\.date) var date
    @Environment(\.location) var location: Location
    @EnvironmentObject var networkManager: NetworkManager
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
        }
    }
}

struct DailyReportLoadingFailedView: View {
    @Environment(\.date) var date
    @Environment(\.location) var location: Location
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
                            try await networkManager.updateSunData(at: location, on: date)
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
