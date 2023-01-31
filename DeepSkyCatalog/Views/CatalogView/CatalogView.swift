//
//  CatalogView.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/6/22.
//

import SwiftUI

struct CatalogView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    @FetchRequest(sortDescriptors: []) var targetSettings: FetchedResults<TargetSettings>
    @StateObject var viewModel: CatalogManager
    @Binding var date: Date
    
    init(date: Binding<Date>, location: SavedLocation, targetSettings: TargetSettings) {
        self._viewModel = StateObject(wrappedValue: CatalogManager(location: location, date: date, targetSettings: targetSettings))
        self._date = date
    }
        
    var body: some View {
        // Only display targets if network data is available
        if let data = networkManager.data[.init(date: date, location: locationList.first!)] {
            NavigationStack() {
                SearchBar(updateAction: { viewModel.refreshList(sunData: data.sun) })
                FilterButtonMenu()
                
                List(viewModel.targets, id: \.id) { target in
                    NavigationLink(destination: DetailView(target: target)) {
                        VStack {
                            TargetCell(target: target)
                        }
                    }
                }
                .listStyle(.grouped)
                .toolbar() {
                    CatalogToolbar(date: $date)
                }
            }
            
            // Modals for editing each filter
            .filterModal(isPresented: $viewModel.isAllFilterModal, viewModel: viewModel) {
                EditAllFiltersView(viewModel: viewModel)
            }
            .filterModal(isPresented: $viewModel.isTypeModal, viewModel: viewModel) {
                SelectableList(selection: $viewModel.typeSelection)
            }
            .filterModal(isPresented: $viewModel.isCatalogModal, viewModel: viewModel) {
                SelectableList(selection: $viewModel.catalogSelection)
            }
            .filterModal(isPresented: $viewModel.isConstellationModal, viewModel: viewModel) {
                SelectableList(selection: $viewModel.constellationSelection)
            }
            .filterModal(isPresented: $viewModel.isMagModal, viewModel: viewModel) {
                MinMaxPicker(min: $viewModel.brightestMag, max: $viewModel.dimmestMag, maxTitle: "Brighter than", minTitle: "Dimmer than", placeValues: [.ones, .tenths])
            }
            .filterModal(isPresented: $viewModel.isSizeModal, viewModel: viewModel) {
                MinMaxPicker(min: $viewModel.minSize, max: $viewModel.maxSize, maxTitle: "Largest Size", minTitle: "Smallest Size", placeValues: [.hundreds, .tens, .ones])
            }
            .filterModal(isPresented: $viewModel.isVisScoreModal, viewModel: viewModel) {
                Form {
                    NumberPicker(num: $viewModel.minVisScore, placeValues: [.tenths, .hundredths])
                }
            }
            .filterModal(isPresented: $viewModel.isMerScoreModal, viewModel: viewModel) {
                Form {
                    NumberPicker(num: $viewModel.minMerScore, placeValues: [.tenths, .hundredths])
                }
            }
            
            // When the date changes, make sure everything that depends on the date gets updated
            .onChange(of: date) { newDate in
                viewModel.refreshList(sunData: data.sun)
            }
            
            // When the location changes, make sure everything that depends on the date gets updated
            .onChange(of: locationList.first) { newLocation in
                viewModel.location = newLocation!
                viewModel.refreshList(sunData: data.sun)
            }
            
            // When target settings change, refresh the list
            .onReceive(viewModel.targetSettings.objectWillChange) { _ in
                viewModel.refreshList(sunData: data.sun)
            }
            
            // Passing the date and location to use into all child views
            .environment(\.date, date)
            .environmentObject(locationList.first!)
            .environmentObject(targetSettings.first!)
            .environmentObject(viewModel)
            .environment(\.data, data)
        }

        // If network data is not available then show a loading icon
        else {
            VStack {
                ProgressView()
                Text("Fetching Sun/Moon Data...")
            }
            .task {
                await networkManager.getData(at: locationList.first!, on: date)
            }
        }
    }
}

/**
 This View displays information about the target at a glance. It is used within the Master Catalog list.
 */
private struct TargetCell: View {
    @EnvironmentObject var location: SavedLocation
    @EnvironmentObject var targetSettings: TargetSettings
    @Environment(\.date) var date
    @Environment(\.data) var data
    var target: DeepSkyObject
    
    var body: some View {
        HStack {                
            Image(target.image?.source.fileName ?? "\(target.type.first!)")
                .resizable()
                .scaledToFit()
                .cornerRadius(8)
                .frame(width: 100, height: 70)
            VStack(alignment: .leading) {
                Text(target.name?[0] ?? target.defaultName)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Label(target.getVisibilityScore(at: location, on: date, sunData: data.sun, limitingAlt: targetSettings.limitingAltitude).percent(), systemImage: "eye")
                    .foregroundColor(.secondary)
                Label(target.getMeridianScore(at: location, on: date, sunData: data.sun).percent(), systemImage: "arrow.right.and.line.vertical.and.arrow.left")
                    .foregroundColor(.secondary)
            }
        }
    }
}

/**
 This View displays a horizontal scrolling section of different filter buttons.
 The filter buttons are explicity defined in an array.
 The array allows them to be sorted based on which ones are active.
 */
private struct FilterButtonMenu: View {
    @EnvironmentObject var viewModel: CatalogManager
    
    var body: some View {
        let buttons = [
            FilterButton(method: .catalog, active: viewModel.isActive(criteria: viewModel.catalogSelection), modalControl: $viewModel.isCatalogModal),
            FilterButton(method: .constellation, active: viewModel.isActive(criteria: viewModel.constellationSelection), modalControl: $viewModel.isConstellationModal),
            FilterButton(method: .type, active: viewModel.isActive(criteria: viewModel.typeSelection), modalControl: $viewModel.isTypeModal),
            FilterButton(method: .magnitude, active: viewModel.isActive(criteria: (min: viewModel.brightestMag, max: viewModel.dimmestMag)), modalControl: $viewModel.isMagModal),
            FilterButton(method: .size, active: viewModel.isActive(criteria: (min: viewModel.minSize, max: viewModel.maxSize)), modalControl: $viewModel.isSizeModal),
            FilterButton(method: .visibility, active: viewModel.isActive(criteria: viewModel.minVisScore), modalControl: $viewModel.isVisScoreModal),
            FilterButton(method: .meridian, active: viewModel.isActive(criteria: viewModel.minMerScore), modalControl: $viewModel.isMerScoreModal)
        ].sorted(by: {$0.active && !$1.active})
        
        HStack {
            // All filters button
            ZStack {
                Rectangle()
                    .frame(width: 40, height: 30)
                    .cornerRadius(13)
                    .foregroundColor(Color(!buttons.allSatisfy({$0.active == false}) ? "LightBlue" : "LightGray"))
                Button {
                    viewModel.isAllFilterModal = true
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
    }
}

/**
 This View defines a singular filter button for a given filter method.
 */
private struct FilterButton: View {
    @EnvironmentObject var viewModel: CatalogManager
    @EnvironmentObject var location: SavedLocation
    @Environment(\.date) var date
    @Environment(\.data) var data
    let method: FilterMethod
    let active: Bool
    @Binding var modalControl: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: method.info.name.widthOfString(usingFont: UIFont.systemFont(ofSize: 20)) + 70, height: 30)
                .cornerRadius(13)
                .foregroundColor(Color(active ? "LightBlue" : "LightGray"))
            Button {
                modalControl = true
            } label: {
                HStack {
                    Label(method.info.name, systemImage: method.info.icon)
                        .foregroundColor(.primary)
                    Button {
                        viewModel.clearFilter(for: method)
                        viewModel.refreshList(sunData: data.sun)
                    } label: {
                        Image(systemName: active ? "x.circle" : "chevron.down")
                            .foregroundColor(.accentColor)
                    }
                    .disabled(!active)
                }
            }
        }
    }
}

/**
 This View contains the ToolbarContent to be displayed in the Master Catalog
 */
private struct CatalogToolbar: ToolbarContent {
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    @Binding var date: Date
    
    var body: some ToolbarContent {
        
        // Custom binding to select and get the selected location
        let locationBinding = Binding(
            get: { return locationList.first! },
            set: {
                for location in locationList { location.isSelected = false }
                $0.isSelected = true
            }
        )
        
        // The Location selector on the left hand side
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Picker("Location", selection: locationBinding) {
                ForEach(locationList) { location in
                    Text(location.name!).tag(location)
                }
            }
            .padding(.horizontal)
        }
        
        // The DateSelector on the right hand side
        ToolbarItem(placement: .navigationBarTrailing) {
            DateSelector(date: $date)
                .padding(.horizontal)
        }
    }
}

/**
 A Search Bar that binds its text to a given variable and executes a given action when text is submitted
 */
private struct SearchBar: View {
    @EnvironmentObject var viewModel: CatalogManager
    @FocusState var isInputActive: Bool
    var updateAction: () -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color("LightGray"))
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $viewModel.searchText)
                    .onSubmit(updateAction)
                    .focused($isInputActive)
            }
            .foregroundColor(.black)
            .padding(.leading, 13)
        }
        .frame(height: 40)
        .cornerRadius(13)
        .padding()
        .toolbar {
            KeyboardDismissButton(isInputActive: _isInputActive)
        }
    }
}

//struct Catalog_Previews: PreviewProvider {
//    static var previews: some View {
//        CatalogView()
//            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
//    }
//}
