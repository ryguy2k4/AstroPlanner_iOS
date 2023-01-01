//
//  EditAllFiltersView.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/30/22.
//

import SwiftUI

struct EditAllFiltersView: View {
    @ObservedObject var viewModel: CatalogViewModel
    @EnvironmentObject var location: SavedLocation
    @Environment(\.data) var data
    @Environment(\.date) var date
    var body: some View {
        NavigationStack {
            Form {
                ConfigSection(header: "Sort") {
                    Picker("Method:", selection: $viewModel.currentSort) {
                        ForEach(SortMethod.allCases) { method in
                            Label("Sort by \(method.info.name)", systemImage: method.info.icon).tag(method)
                        }
                    }
                    .onChange(of: viewModel.currentSort) { newMethod in
                        viewModel.targets.sort(by: newMethod, sortDescending: viewModel.sortDecending, location: location, date: date, sunData: data.sun)
                    }
                    Picker("Order:", selection: $viewModel.sortDecending) {
                        Label("Ascending", systemImage: "chevron.up").tag(false)
                        Label("Descending", systemImage: "chevron.down").tag(true)
                                
                    }
                    .onChange(of: viewModel.sortDecending) { newOrder in
                        viewModel.targets.sort(by: viewModel.currentSort, sortDescending: newOrder, location: location, date: date, sunData: data.sun)
                    }
                }
                ConfigSection(header: "Filters") {
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
                        MinMaxPicker(min: $viewModel.brightestMag, max: $viewModel.dimmestMag, maxTitle: "Brighter than", minTitle: "Dimmer than", placeValues: [.ones, .tenths])
                    }
                    NavigationLink("Size Filter") {
                        MinMaxPicker(min: $viewModel.minSize, max: $viewModel.maxSize, maxTitle: "Largest Size", minTitle: "Smallest Size", placeValues: [.hundreds, .tens, .ones])
                    }
                    NavigationLink("Visibility Score Filter") {
                        Form {
                            NumberPicker(num: $viewModel.minVisScore, placeValues: [.tenths, .hundredths])
                        }
                    }
                    NavigationLink("Meridian Score Filter") {
                        Form {
                            NumberPicker(num: $viewModel.minMerScore, placeValues: [.tenths, .hundredths])
                        }
                    }
                }
            }
        }
    }
}

//struct EditAllFiltersView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditAllFiltersView()
//    }
//}
