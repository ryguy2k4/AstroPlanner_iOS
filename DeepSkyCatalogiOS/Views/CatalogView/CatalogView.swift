//
//  CatalogView.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/6/22.
//

import SwiftUI
import SwiftData

struct CatalogView: View {
    @Environment(\.dismissSearch) private var dismissSearch
    @Environment(\.isSearching) private var isSearching
    @Environment(\.modelContext) var context
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var locationManager: LocationManager
    @StateObject private var catalogManager: CatalogManager = CatalogManager(targets: DeepSkyTargetList.allTargets)

    @Query var targetSettings: [TargetSettings]

    @EnvironmentObject var store: HomeViewModel
    @State private var isLocationModal = false
    @State private var isDateModal = false

    var body: some View {
        NavigationStack() {
            FilterButtonMenu()
            
            List(catalogManager.targets, id: \.id) { target in
                NavigationLink(destination: DetailView(target: target)) {
                    VStack {
                        TargetCell(target: target)
                            .environmentObject(store)
                    }
                }
            }
            .listStyle(.grouped)
            .toolbar() {
                ToolbarLogo()
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isDateModal = true
                    } label: {
                        Image(systemName: "calendar")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isLocationModal = true
                    } label: {
                        Image(systemName: "location")
                    }
                }
            }
        }
        
        // Modifiers to enable searching
        .searchable(text: $catalogManager.searchText)
        .onSubmit(of: .search) {
            catalogManager.refreshList(date: store.date, viewingInterval: store.viewingInterval, location: store.location, targetSettings: targetSettings.first!, sunData: store.sunData, context: context)
        }
        .onChange(of: catalogManager.searchText) { newValue in
            if newValue.isEmpty {
                catalogManager.refreshList(date: store.date, viewingInterval: store.viewingInterval, location: store.location, targetSettings: targetSettings.first!, sunData: store.sunData, context: context)
            }
        }
//        .searchSuggestions {
//            // grab top 15 search results
//            let suggestions = DeepSkyTargetList.whitelistedTargets.filteredBySearch(catalogManager.searchText)
//            
//            // list the search results
//            ForEach(suggestions) { suggestion in
//                HStack {
//                    Image(suggestion.image?.source.fileName ?? "\(suggestion.type)")
//                        .resizable()
//                        .scaledToFit()
//                        .cornerRadius(8)
//                        .frame(width: 100, height: 70)
//                    Text(suggestion.name?.first ?? suggestion.defaultName)
//                        .foregroundColor(.primary)
//                }.searchCompletion(suggestion.name?.first ?? suggestion.defaultName)
//            }
//        }
        .onChange(of: isSearching) { newValue in
            if !isSearching {
                dismissSearch()
            }
        }
        .autocorrectionDisabled()
        
        // Modal for settings
        .sheet(isPresented: $isDateModal){
            ViewingIntervalModal()
                .environmentObject(store)
                .environment(\.timeZone, store.location.timezone)
                .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
        }
        .sheet(isPresented: $isLocationModal){
            LocationPickerModal()
                .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
        }
        // Passing the date and location to use into all child views
        .environmentObject(catalogManager)
    }
}

/**
 This View displays information about the target at a glance. It is used within the Master Catalog list.
 */
fileprivate struct TargetCell: View {
    @Query var targetSettings: [TargetSettings]
    var target: DeepSkyTarget
    @EnvironmentObject var store: HomeViewModel

    var body: some View {
        HStack {                
            Image(target.image?.source.fileName ?? "\(target.type)")
                .resizable()
                .scaledToFit()
                .cornerRadius(8)
                .frame(width: 100, height: 70)
            VStack(alignment: .leading) {
                Text(target.name?[0] ?? target.defaultName)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Label(target.getVisibilityScore(at: store.location, viewingInterval: store.viewingInterval, sunData: store.sunData, limitingAlt: targetSettings.first?.limitingAltitude ?? 0).percent(), systemImage: "eye")
                    .foregroundColor(.secondary)
                Label(target.getSeasonScore(at: store.location, on: store.date, sunData: store.sunData).percent(), systemImage: "calendar.circle")
                    .foregroundColor(.secondary)
            }
        }
    }
}

//struct Catalog_Previews: PreviewProvider {
//    static var previews: some View {
//        CatalogView()
//            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
//    }
//}
