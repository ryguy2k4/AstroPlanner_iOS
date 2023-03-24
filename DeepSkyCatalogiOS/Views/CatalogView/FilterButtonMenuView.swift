//
//  FilterButtonMenuView.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 3/16/23.
//

import SwiftUI

/**
 This View displays a horizontal scrolling section of different filter buttons.
 The filter buttons are explicity defined in an array.
 The array allows them to be sorted based on which ones are active.
 */
struct FilterButtonMenu: View {
    @EnvironmentObject var viewModel: CatalogManager
    @Environment(\.location) var location: Location
    @Environment(\.sunData) var sunData
    @Environment(\.viewingInterval) var viewingInterval
    @FetchRequest(sortDescriptors: []) var targetSettings: FetchedResults<TargetSettings>
    @Binding var date: Date
    @State private var isAllFilterModal: Bool = false
    
    var body: some View {
        let buttons: [FilterButton] = {
            var buttons: [FilterButton] = []
            buttons.append(FilterButton(method: .type, active: viewModel.isActive(criteria: viewModel.typeSelection)))
            buttons.append(FilterButton(method: .size, active: viewModel.isActive(criteria: (min: viewModel.minSize, max: viewModel.maxSize))))
            buttons.append(FilterButton(method: .catalog, active: viewModel.isActive(criteria: viewModel.catalogSelection)))
            buttons.append(FilterButton(method: .constellation, active: viewModel.isActive(criteria: viewModel.constellationSelection)))
            buttons.append(FilterButton(method: .magnitude, active: viewModel.isActive(criteria: (min: viewModel.brightestMag, max: viewModel.dimmestMag))))
            if sunData != nil {
                buttons.append(FilterButton(method: .visibility, active: viewModel.isActive(criteria: viewModel.minVisScore)))
                buttons.append(FilterButton(method: .seasonScore, active: viewModel.isActive(criteria: viewModel.minSeasonScore)))
            }
            return buttons.sorted(by: {$0.active && !$1.active})
        }()
        
        HStack {
            // All filters button
            ZStack {
                Rectangle()
                    .frame(width: 40, height: 30)
                    .cornerRadius(13)
                    .foregroundColor(Color(!buttons.allSatisfy({$0.active == false}) ? "LightBlue" : "LightGray"))
                Button {
                    isAllFilterModal = true
                } label: {
                    Image(systemName: "camera.filters")
                        .foregroundColor(.primary)
                }
            }
            
            // Display each individual filter button
            ScrollView(.horizontal) {
                HStack {
                    ForEach(buttons, id: \.method) { button in
                        button
                    }
                }
            }
        }
        .padding(.horizontal)
        .scrollIndicators(.hidden)
        
        // Modal for editing all filters
        .sheet(isPresented: $isAllFilterModal) {
            EditAllFiltersView(viewModel: viewModel, dateBinding: $date)
                .onDisappear() {
                    viewModel.refreshList(date: date, viewingInterval: viewingInterval, location: location, targetSettings: targetSettings.first!, sunData: sunData)
                }
                .presentationDetents([.fraction(0.5), .fraction(0.8)])
        }
        
    }
}

/**
 This View defines a singular filter button for a given filter method.
 */
fileprivate struct FilterButton: View {
    @EnvironmentObject var viewModel: CatalogManager
    @Environment(\.location) var location: Location
    @Environment(\.date) var date
    @Environment(\.sunData) var sunData
    @Environment(\.viewingInterval) var viewingInterval
    @FetchRequest(sortDescriptors: []) var targetSettings: FetchedResults<TargetSettings>
    @State private var presentedFilterSheet: FilterMethod? = nil
    let method: FilterMethod
    let active: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: method.info.name.widthOfString(usingFont: UIFont.systemFont(ofSize: 20)) + 70, height: 30)
                .cornerRadius(13)
                .foregroundColor(Color(active ? "LightBlue" : "LightGray"))
            Button {
                presentedFilterSheet = method
            } label: {
                HStack {
                    Label(method.info.name, systemImage: method.info.icon)
                        .foregroundColor(.primary)
                    Button {
                        viewModel.clearFilter(for: method)
                        viewModel.refreshList(date: date, viewingInterval: viewingInterval, location: location, targetSettings: targetSettings.first!, sunData: sunData)
                    } label: {
                        Image(systemName: active ? "x.circle" : "chevron.down")
                            .foregroundColor(.accentColor)
                    }
                    .disabled(!active)
                }
            }
        }
        // Modals for editing each filter
        .sheet(item: $presentedFilterSheet) { method in
            VStack {
                switch method {
                case .catalog:
                    SelectableList(selection: $viewModel.catalogSelection)
                case .constellation:
                    SelectableList(selection: $viewModel.constellationSelection)
                case .type:
                    SelectableList(selection: $viewModel.typeSelection)
                case .magnitude:
                    MinMaxPicker(min: $viewModel.brightestMag, max: $viewModel.dimmestMag, maxTitle: "Brighter than", minTitle: "Dimmer than", placeValues: [.ones, .tenths])
                case .size:
                    MinMaxPicker(min: $viewModel.minSize, max: $viewModel.maxSize, maxTitle: "Largest Size", minTitle: "Smallest Size", placeValues: [.hundreds, .tens, .ones])
                case .visibility:
                    Form {
                        NumberPicker(num: $viewModel.minVisScore, placeValues: [.tenths, .hundredths])
                    }
                case .seasonScore:
                    Form {
                        NumberPicker(num: $viewModel.minSeasonScore, placeValues: [.tenths, .hundredths])
                    }
                default:
                    EmptyView()
                }
            }
            .onDisappear() {
                viewModel.refreshList(date: date, viewingInterval: viewingInterval, location: location, targetSettings: targetSettings.first!, sunData: sunData)
            }
            .presentationDetents([.fraction(0.5), .fraction(0.8)])
        }
    }
}
