//
//  Mac_HomeView.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 2/4/23.
//

import SwiftUI
import CoreData

struct Mac_HomeView: View {
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
            //CatalogView(date: $date, location: locationList.first!, targetSettings: targetSettings.first!)
            Text("Master Catalog View")
                .tabItem {
                    Label("Master Catalog", systemImage: "tray.full.fill")
                }
            //JournalView()
            Text("Master Catalog View")
                .tabItem {
                    Label("Journal", systemImage: "magazine.fill")
                }
            //SettingsView()
            Text("Settings View")
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .environment(\.date, date)
        }
        .frame(minWidth: 600, maxWidth: 2400, minHeight: 400,  maxHeight: 1600)
    }
}

struct Mac_HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Mac_HomeView()
    }
}
