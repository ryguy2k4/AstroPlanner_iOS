//
//  Mac_SortButtonMenu.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 1/9/24.
//

import SwiftUI
import SwiftData

struct Mac_SortButtonMenu: View {
    @ObservedObject var viewModel: CatalogManager
    @Query(sort: [SortDescriptor(\SavedLocation.name, order: .forward)]) var locations: [SavedLocation]
    @Query var targetSettings: [TargetSettings]
    @Environment(\.modelContext) var context
    @EnvironmentObject var store: HomeViewModel
    
    var body: some View {
        Form {
            Section {
                Picker("Sort Method:", selection: $viewModel.currentSort) {
                    ForEach(store.sunData != .default ? SortMethod.allCases : SortMethod.offlineCases) { method in
                        Label("Sort by \(method.info.name)", systemImage: method.info.icon).tag(method)
                    }
                }
                .onChange(of: viewModel.currentSort) {
                    viewModel.refreshList(date: store.date, viewingInterval: store.viewingInterval, location: store.location, targetSettings: targetSettings.first!, sunData: store.sunData)
                }
                Picker("Sort Order:", selection: $viewModel.sortDecending) {
                    Label("Ascending", systemImage: "chevron.up").tag(false)
                    Label("Descending", systemImage: "chevron.down").tag(true)
                    
                }
                .onChange(of: viewModel.sortDecending) {
                    viewModel.refreshList(date: store.date, viewingInterval: store.viewingInterval, location: store.location, targetSettings: targetSettings.first!, sunData: store.sunData)
                }
            }
        }
        .scrollDisabled(true)
        .padding()
    }
}
