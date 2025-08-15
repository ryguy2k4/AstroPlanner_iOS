//
//  FilterButtonMenuView.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 3/16/23.
//

import SwiftUI
import SwiftData
import DeepSkyCore

/**
 This View displays a horizontal scrolling section of different filter buttons.
 The filter buttons are explicity defined in an array.
 The array allows them to be sorted based on which ones are active.
 */
struct FilterButtonMenu: View {
    @EnvironmentObject var viewModel: CatalogManager
    @EnvironmentObject var store: HomeViewModel
    @Environment(\.modelContext) var context
    @Query var targetSettings: [TargetSettings]
    @State private var isAllFilterModal: Bool = false
    
    var body: some View {
        let buttons: [FilterButton] = {
            var buttons: [FilterButton] = []
            buttons.append(FilterButton(method: .type, active: !viewModel.typeSelection.isEmpty))
            buttons.append(FilterButton(method: .size, active: viewModel.minSize != nil || viewModel.maxSize != nil))
            buttons.append(FilterButton(method: .catalog, active: !viewModel.catalogSelection.isEmpty))
            buttons.append(FilterButton(method: .constellation, active: !viewModel.constellationSelection.isEmpty))
            buttons.append(FilterButton(method: .magnitude, active: viewModel.brightestMag != nil || viewModel.dimmestMag != nil))
            if store.sunData != .default {
                buttons.append(FilterButton(method: .visibility, active: viewModel.minVisScore != nil))
                buttons.append(FilterButton(method: .seasonScore, active: viewModel.minSeasonScore != nil))
            }
            return buttons.sorted(by: {$0.active && !$1.active})
        }()
        
        HStack {
            // All filters button
            ZStack {
                Rectangle()
                    .frame(width: 40, height: 30)
                    .cornerRadius(13)
                    .foregroundColor(!buttons.allSatisfy({$0.active == false}) ? .accentColor.opacity(0.5) : .secondary.opacity(0.3))
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
            EditAllFiltersView(viewModel: viewModel)
                .onDisappear() {
                    viewModel.refreshList(date: store.date, viewingInterval: store.viewingInterval, location: store.location, targetSettings: targetSettings.first!, sunData: store.sunData)
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
    @EnvironmentObject var store: HomeViewModel
    @Environment(\.modelContext) var context
    @Query var targetSettings: [TargetSettings]
    @State private var presentedFilterSheet: FilterMethod? = nil
    let method: FilterMethod
    let active: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: method.info.name.widthOfString(usingFont: UIFont.systemFont(ofSize: 20)) + 70, height: 30)
                .cornerRadius(13)
                .foregroundColor(active ? .accentColor.opacity(0.5) : .secondary.opacity(0.3))
            Button {
                presentedFilterSheet = method
            } label: {
                HStack {
                    Label(method.info.name, systemImage: method.info.icon)
                        .foregroundColor(.primary)
                    // only enabled when filter is applied
                    Button {
                        viewModel.clearFilter(for: method)
                        viewModel.refreshList(date: store.date, viewingInterval: store.viewingInterval, location: store.location, targetSettings: targetSettings.first!, sunData: store.sunData)
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
                    MinMaxPicker(min: $viewModel.brightestMag, max: $viewModel.dimmestMag, minTitle: "Dimmer than", maxTitle: "Brighter than", placeValues: [.ones, .tenths])
                case .size:
                    MinMaxPicker(min: $viewModel.minSize, max: $viewModel.maxSize, minTitle: "Smallest Size", maxTitle: "Largest Size", placeValues: [.hundreds, .tens, .ones])
                case .visibility:
                    Form {
                        OptionalNumberPicker(num: $viewModel.minVisScore, placeValues: [.tenths, .hundredths])
                    }
                case .seasonScore:
                    Form {
                        OptionalNumberPicker(num: $viewModel.minSeasonScore, placeValues: [.tenths, .hundredths])
                    }
                default:
                    EmptyView()
                }
            }
            .onDisappear() {
                viewModel.refreshList(date: store.date, viewingInterval: store.viewingInterval, location: store.location, targetSettings: targetSettings.first!, sunData: store.sunData)
            }
            .presentationDetents([.fraction(0.5), .fraction(0.8)])
        }
    }
}
