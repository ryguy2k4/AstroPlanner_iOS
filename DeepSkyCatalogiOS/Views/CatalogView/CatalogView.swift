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
    @EnvironmentObject var store: HomeViewModel

    @Query var targetSettings: [TargetSettings]
    @Query var reportSettings: [ReportSettings]
    
    @StateObject private var catalogManager: CatalogManager = CatalogManager()
    @State private var isLocationModal = false
    @State private var isDateModal = false
    
    var body: some View {
        NavigationStack() {
            FilterButtonMenu()
            
            if catalogManager.targets.isEmpty {
                ContentUnavailableView.search(text: catalogManager.searchText)
            }
            
            List(catalogManager.targets) { target in
                NavigationLink(destination: DetailView(target: target)) {
                    TargetCell(target: target)
                        .environmentObject(store)
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
            catalogManager.refreshList(date: store.date, viewingInterval: store.viewingInterval, location: store.location, targetSettings: targetSettings.first!, sunData: store.sunData)
        }
        .onChange(of: catalogManager.searchText) { _, newValue in
            if newValue.isEmpty {
                catalogManager.refreshList(date: store.date, viewingInterval: store.viewingInterval, location: store.location, targetSettings: targetSettings.first!, sunData: store.sunData)
            }
        }
        .onChange(of: isSearching) {
            if !isSearching {
                dismissSearch()
            }
        }
        .autocorrectionDisabled()
        
        // Modals for settings
        .sheet(isPresented: $isDateModal){
            ViewingIntervalModal(reportSettings: reportSettings.first!)
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
        
        // When this view loads, initialize the catalog manager from the store
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
            Image(target.image?.filename ?? "\(target.type)")
                .resizable()
                .scaledToFit()
                .cornerRadius(8)
                .frame(width: 100, height: 70)
            VStack(alignment: .leading) {
                Text(target.defaultName)
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
