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
    
    // create non-persistent date and viewingInterval objects
    @State var date: Date = Date.today
    @State var viewingInterval: DateInterval = DateInterval(start: Date.today.addingTimeInterval(68400), end: Date.tomorrow.addingTimeInterval(18000))
    
    var body: some View {
        TabView {
            DailyReportView(date: $date, viewingInterval: $viewingInterval)
                .tabItem {
                    Label("Daily Report", systemImage: "doc.text")
                }
            CatalogView(date: $date, viewingInterval: $viewingInterval)
                .tabItem {
                    Label("Master Catalog", systemImage: "tray.full.fill")
                }
//            JournalView()
//                .tabItem {
//                    Label("Journal", systemImage: "magazine.fill")
//                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .environment(\.date, date)
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
