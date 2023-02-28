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
    @State var viewingInterval: DateInterval = DateInterval(start: Date.today.addingTimeInterval(68400), end: Date.tomorrow.addingTimeInterval(18000))
    
    enum SidebarItem: String, Identifiable, CaseIterable {
        var id: Self { self }
        case report = "Daily Report"
        case catalog = "Master Catalog"
        case journal = "Journal"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .report: return "doc.text"
            case .catalog: return "tray.full.fill"
            case .journal: return "magazine.fill"
            case .settings: return "gearshape"
            }
        }
    }
    
    @State var sidebarVisibility: NavigationSplitViewVisibility = .automatic
    @State var sidebarItem: SidebarItem = .report
    
    
    var body: some View {
        NavigationSplitView(columnVisibility: $sidebarVisibility) {
            List(SidebarItem.allCases, selection: $sidebarItem) { item in
                Label(item.rawValue, systemImage: item.icon)
            }
        } detail: {
            switch sidebarItem {
            case .report:
                DailyReportView(date: $date, viewingInterval: $viewingInterval)
            case .catalog:
                CatalogView(date: $date, viewingInterval: $viewingInterval, location: locationList.first!, targetSettings: targetSettings.first!)
            case .journal:
                Text("Under Construction")
            case .settings:
                Text("Under Construction")
            }
        }
        .frame(minWidth: 600, maxWidth: 2400, minHeight: 400,  maxHeight: 1600)
    }
}

//struct Mac_HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        Mac_HomeView()
//    }
//}
