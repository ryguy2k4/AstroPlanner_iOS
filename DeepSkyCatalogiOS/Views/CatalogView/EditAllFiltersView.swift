//
//  EditAllFiltersView.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/30/22.
//

import SwiftUI

struct EditAllFiltersView: View {
    @ObservedObject var viewModel: CatalogManager
    @EnvironmentObject var location: SavedLocation
    @EnvironmentObject var reportSettings: ReportSettings
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    @Environment(\.managedObjectContext) var context
    @Environment(\.data) var data
    @Environment(\.date) var date
    @Binding var dateBinding: Date
    
    var body: some View {
        NavigationStack {
            Form {
                ConfigSection(header: "Sort") {
                    Picker("Method:", selection: $viewModel.currentSort) {
                        ForEach(data != nil ? SortMethod.allCases : SortMethod.offlineCases) { method in
                            Label("Sort by \(method.info.name)", systemImage: method.info.icon).tag(method)
                        }
                    }
                    .onChange(of: viewModel.currentSort) { _ in
                        viewModel.refreshList(sunData: data?.sun)
                    }
                    Picker("Order:", selection: $viewModel.sortDecending) {
                        Label("Ascending", systemImage: "chevron.up").tag(false)
                        Label("Descending", systemImage: "chevron.down").tag(true)
                        
                    }
                    .onChange(of: viewModel.sortDecending) { _ in
                        viewModel.refreshList(sunData: data?.sun)
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
                    if data != nil {
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
}

//struct EditAllFiltersView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditAllFiltersView()
//    }
//}
