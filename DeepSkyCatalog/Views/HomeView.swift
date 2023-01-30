//
//  HomeView.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/2/22.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var networkManager: NetworkManager
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse), SortDescriptor(\SavedLocation.name, order: .forward)]) var locationList: FetchedResults<SavedLocation>
    @FetchRequest(sortDescriptors: []) var reportSettings: FetchedResults<ReportSettings>
    @FetchRequest(sortDescriptors: []) var targetSettings: FetchedResults<TargetSettings>
    @State var date: Date = Date.today
    var body: some View {
        TabView {
            DailyReportView(date: $date)
                .tabItem {
                    Label("Daily Report", systemImage: "doc.text")
                }
            CatalogView(date: $date, location: locationList.first!, targetSettings: targetSettings.first!)
                .tabItem {
                    Label("Master Catalog", systemImage: "tray.full.fill")
                }
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "magazine.fill")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.managedObjectContext, PersistenceManager.shared.container.viewContext)
            .environmentObject(NetworkManager.shared)
    }
}
