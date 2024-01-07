//
//  Mac_CatalogView.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 7/13/23.
//

import SwiftUI
import SwiftData

struct Mac_CatalogView: View {
    @Environment(\.dismissSearch) private var dismissSearch
    @Environment(\.isSearching) private var isSearching
    @Environment(\.modelContext) var context
    @EnvironmentObject var store: HomeViewModel

    @Query var targetSettings: [TargetSettings]
    @Query var reportSettings: [ReportSettings]
    
    @StateObject private var catalogManager: CatalogManager = CatalogManager()

    var body: some View {
        NavigationStack {            
            List(catalogManager.targets, id: \.id) { target in
                NavigationLink(destination: Mac_DetailView(target: target).environmentObject(store)) {
                    VStack {
                        TargetCell(target: target)
                            .environmentObject(store)
                    }
                }
            }
        }
        
        .toolbar {
            Mac_FilterButtonMenu()
        }
        
        // Modifiers to enable searching
        .searchable(text: $catalogManager.searchText, placement: .toolbar)
        .onSubmit(of: .search) {
            catalogManager.refreshList(date: store.date, viewingInterval: store.viewingInterval, location: store.location, targetSettings: targetSettings.first!, sunData: store.sunData)
        }
        .onChange(of: catalogManager.searchText) { _, newValue in
            if newValue.isEmpty {
                catalogManager.refreshList(date: store.date, viewingInterval: store.viewingInterval, location: store.location, targetSettings: targetSettings.first!, sunData: store.sunData)
            }
        }
        .onChange(of: isSearching) { _, newValue in
            if !isSearching {
                dismissSearch()
            }
        }
        .autocorrectionDisabled()

        // Passing the date and location to use into all child views
        .environmentObject(catalogManager)
        
        .navigationTitle("Master Catalog | " + (store.viewingInterval == store.sunData.ATInterval ? "Night of \(DateFormatter.longDateOnly(timezone: store.location.timezone).string(from: store.date)) | \(store.location.name)" : "\(store.viewingInterval.start.formatted(date: .abbreviated, time: .shortened)) to \(store.viewingInterval.end.formatted(date: .omitted, time: .shortened)) at \(store.location.name)"))
        .task {
            catalogManager.refreshList(date: store.date, viewingInterval: store.viewingInterval, location: store.location, targetSettings: targetSettings.first!, sunData: store.sunData)
        }
    }
}

/**
 This View displays information about the target at a glance. It is used within the Master Catalog list.
 */
fileprivate struct TargetCell: View {
    @EnvironmentObject var store: HomeViewModel
    @Query var targetSettings: [TargetSettings]
    var target: DeepSkyTarget

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
                Label(target.getVisibilityScore(at: store.location, viewingInterval: store.viewingInterval, limitingAlt: targetSettings.first?.limitingAltitude ?? 0).percent(), systemImage: "eye")
                    .foregroundColor(.secondary)
                Label(target.getSeasonScore(at: store.location, on: store.date, sunData: store.sunData).percent(), systemImage: "calendar.circle")
                    .foregroundColor(.secondary)
            }
        }
    }
}
