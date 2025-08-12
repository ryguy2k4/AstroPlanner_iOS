//
//  Mac_FilterButtonMenu.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 1/2/24.
//

import SwiftUI
import SwiftData

struct Mac_FilterButtonMenu: View {
    @EnvironmentObject var viewModel: CatalogManager
    @EnvironmentObject var store: HomeViewModel
    @Environment(\.modelContext) var context
    @Query var targetSettings: [TargetSettings]
    @State private var sortModal: Bool = false
    
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
            // Sort button
            ZStack {
                Rectangle()
                    .frame(width: 40, height: 30)
                    .cornerRadius(13)
                    .foregroundColor(.secondary.opacity(0.4))
                Button {
                    sortModal = true
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
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
        
        // Modal for sorting
        .sheet(isPresented: $sortModal) {
            Mac_SortButtonMenu(viewModel: viewModel)
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
        Button {
            presentedFilterSheet = method
        } label: {
            HStack {
                Label(method.info.name, systemImage: method.info.icon)
                    .foregroundColor(.primary)
                Button {
                    viewModel.clearFilter(for: method)
                    viewModel.refreshList(date: store.date, viewingInterval: store.viewingInterval, location: store.location, targetSettings: targetSettings.first!, sunData: store.sunData)
                } label: {
                    Image(systemName: active ? "x.circle" : "chevron.down")
                        .foregroundColor(.accentColor)
                }
                .disabled(!active)
                .buttonStyle(.borderless)
            }
        }
        .background(active ? Color.accentColor.opacity(0.3) : Color.secondary.opacity(0.3))
        // Modals for editing each filter
        .sheet(item: $presentedFilterSheet) { method in
            VStack {
//                switch method {
//                case .catalog:
//                    SelectableList(selection: $viewModel.catalogSelection)
//                case .constellation:
//                    SelectableList(selection: $viewModel.constellationSelection)
//                case .type:
//                    SelectableList(selection: $viewModel.typeSelection)
//                case .magnitude:
//                    Mac_MinMaxPicker(min: $viewModel.brightestMag, max: $viewModel.dimmestMag, minTitle: "Brighter than", maxTitle: "Dimmer than")
//                case .size:
//                    Mac_MinMaxPicker(min: $viewModel.minSize, max: $viewModel.maxSize, minTitle: "Larger than", maxTitle: "Smaller than")
//                case .visibility:
//                    Mac_MinMaxPicker(min: $viewModel.minVisScore, percent: true)
//                case .seasonScore:
//                    Mac_MinMaxPicker(min: $viewModel.minSeasonScore, percent: true)
//                default:
//                    EmptyView()
//                }
                Text("Not Working")
            }
            .onDisappear() {
                viewModel.refreshList(date: store.date, viewingInterval: store.viewingInterval, location: store.location, targetSettings: targetSettings.first!, sunData: store.sunData)
            }
            .presentationDetents([.fraction(0.5), .fraction(0.8)])
        }
    }
}

