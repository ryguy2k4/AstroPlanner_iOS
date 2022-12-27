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
    @State var date: Date = Date.today
    var body: some View {
        TabView {
            DailyReportView(date: $date)
                .tabItem {
                    Label("Daily Report", systemImage: "doc.text")
                }
            CatalogView(date: $date, location: locationList.first!)
                .tabItem {
                    Label("Master Catalog", systemImage: "tray.full.fill")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
    }
}

//struct BigButton: View {
//    var text: String
//    var body: some View {
//        Text(text)
//            .frame(width:280, height: 50)
//            .font(.title2)
//            .fontWeight(.semibold)
//            .foregroundColor(.primary)
//            .background(.blue)
//            .cornerRadius(10)
//    }
//}

//struct MainImage: View {
//    var url: URL
//    var body: some View {
//        AsyncImage(url: url, content: { image in
//            image
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 300)
//
//        }, placeholder: {
//            ProgressView()
//        })
//    }
//}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.managedObjectContext, PersistenceManager.shared.container.viewContext)
            .environmentObject(NetworkManager.shared)
    }
}
