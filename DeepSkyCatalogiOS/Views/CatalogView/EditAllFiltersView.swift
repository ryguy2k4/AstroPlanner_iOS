//
//  EditAllFiltersView.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/30/22.
//

import SwiftUI
import SwiftData
import DeepSkyCore

struct EditAllFiltersView: View {
    @ObservedObject var viewModel: CatalogManager
    @Query(sort: [SortDescriptor(\SavedLocation.name, order: .forward)]) var locations: [SavedLocation]
    @Query var targetSettings: [TargetSettings]
    @Environment(\.modelContext) var context
    @EnvironmentObject var store: HomeViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Method:", selection: $viewModel.currentSort) {
                        ForEach(store.sunData != .default ? SortMethod.allCases : SortMethod.offlineCases) { method in
                            Label("Sort by \(method.info.name)", systemImage: method.info.icon).tag(method)
                        }
                    }
                    .onChange(of: viewModel.currentSort) {
                        viewModel.refreshList(date: store.date, viewingInterval: store.viewingInterval, location: store.location, targetSettings: targetSettings.first!, sunData: store.sunData)
                    }
                    Picker("Order:", selection: $viewModel.sortDecending) {
                        Label("Ascending", systemImage: "chevron.up").tag(false)
                        Label("Descending", systemImage: "chevron.down").tag(true)
                        
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.sortDecending) {
                        viewModel.refreshSortOrder()
                    }
                } header: {
                    Text("Sort")
                }
                Section {
                    NavigationLink("Catalog Filter") {
                        SelectableList(selection: $viewModel.catalogSelection)
                    }
                    NavigationLink("Type Filter") {
                        SelectableList(selection: $viewModel.typeSelection)
                    }
                    NavigationLink("Constellation Filter") {
                        SelectableList(selection: $viewModel.constellationSelection)
                    }
                    NavigationLink("Magnitude Filter") {
                        MinMaxPicker(min: $viewModel.brightestMag, max: $viewModel.dimmestMag, minTitle: "Dimmer than", maxTitle: "Brighter than", placeValues: [.ones, .tenths])
                    }
                    NavigationLink("Size Filter") {
                        MinMaxPicker(min: $viewModel.minSize, max: $viewModel.maxSize, minTitle: "Smallest Size", maxTitle: "Largest Size", placeValues: [.hundreds, .tens, .ones])
                    }
                    if store.sunData != .default {
                        NavigationLink("Visibility Score Filter") {
                            Form {
                                OptionalNumberPicker(num: $viewModel.minVisScore, placeValues: [.tenths, .hundredths])
                            }
                        }
                        NavigationLink("Season Score Filter") {
                            Form {
                                OptionalNumberPicker(num: $viewModel.minSeasonScore, placeValues: [.tenths, .hundredths])
                            }
                        }
                    }
                } header: {
                    Text("Filters")
                }
            }
            .scrollDisabled(true)
        }
    }
}

//struct EditAllFiltersView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditAllFiltersView()
//    }
//}
