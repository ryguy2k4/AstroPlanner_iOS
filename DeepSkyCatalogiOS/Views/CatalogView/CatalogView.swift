//
//  CatalogView.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/6/22.
//

import SwiftUI

struct CatalogView: View {
    @Environment(\.dismissSearch) private var dismissSearch
    @Environment(\.isSearching) private var isSearching
    @EnvironmentObject var networkManager: NetworkManager
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    @FetchRequest(sortDescriptors: []) var targetSettings: FetchedResults<TargetSettings>
    @StateObject private var viewModel: CatalogManager
    @Binding var date: Date
    @Binding var viewingInterval: DateInterval
    @State private var isSettingsModal = false

    
    init(date: Binding<Date>, viewingInterval: Binding<DateInterval>, location: SavedLocation, targetSettings: TargetSettings) {
        self._viewModel = StateObject(wrappedValue: CatalogManager(location: location, date: date, viewingInterval: viewingInterval, targetSettings: targetSettings))
        self._date = date
        self._viewingInterval = viewingInterval
    }
        
    var body: some View {
        // Only display targets if network data is available
        let data = networkManager.data[.init(date: date, location: locationList.first!)]
        NavigationStack() {
            FilterButtonMenu(date: $date)
            
            List(viewModel.targets, id: \.id) { target in
                NavigationLink(destination: DetailView(target: target)) {
                    VStack {
                        TargetCell(target: target)
                    }
                }
            }
            .listStyle(.grouped)
            .toolbar() {
                ToolbarLogo()
                if data == nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Image(systemName: "wifi.exclamationmark")
                            .foregroundColor(.red)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isSettingsModal = true
                    } label: {
                        HStack {
                            Image(systemName: "location")
                            Image(systemName: "calendar")
                        }
                    }
                }
            }
        }
        
        // Modifiers to enable searching
        .searchable(text: $viewModel.searchText)
        .onSubmit(of: .search) {
            viewModel.refreshList(sunData: data?.sun)
        }
        .onChange(of: viewModel.searchText) { newValue in
            if newValue.isEmpty {
                viewModel.refreshList(sunData: data?.sun)
            }
        }
        .searchSuggestions {
            // grab top 15 search results
            let suggestions = DeepSkyTargetList.objects.filteredBySearch(viewModel.searchText)
            
            // list the search results
            ForEach(suggestions) { suggestion in
                HStack {
                    Image(suggestion.image?.source.fileName ?? "\(suggestion.type)")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
                        .frame(width: 100, height: 70)
                    Text(suggestion.name?.first ?? suggestion.defaultName)
                        .foregroundColor(.primary)
                }.searchCompletion(suggestion.name?.first ?? suggestion.defaultName)
            }
        }
        .onChange(of: isSearching) { newValue in
            if !isSearching {
                dismissSearch()
            }
        }
        .autocorrectionDisabled()
        
        // Modal for settings
        .sheet(isPresented: $isSettingsModal){
            CatalogViewSettings(date: $date, viewingInterval: $viewingInterval)
                .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
                .disabled(data == nil)
        }
        
        // When the date changes, make sure everything that depends on the date gets updated
        .onChange(of: date) { newDate in
            viewModel.refreshList(sunData: data?.sun)
        }
        
        // When the location changes, make sure everything that depends on the date gets updated
        .onChange(of: locationList.first) { newLocation in
            viewModel.location = newLocation!
            viewModel.refreshList(sunData: data?.sun)
        }
        
        // When target settings change, refresh the list
        .onReceive(viewModel.targetSettings.objectWillChange) { _ in
            viewModel.refreshList(sunData: data?.sun)
        }
        
        // Passing the date and location to use into all child views
        .environment(\.date, date)
        .environmentObject(locationList.first!)
        .environmentObject(targetSettings.first!)
        .environmentObject(viewModel)
        .environment(\.data, data)
    }
}

/**
 This View displays information about the target at a glance. It is used within the Master Catalog list.
 */
fileprivate struct TargetCell: View {
    @EnvironmentObject var location: SavedLocation
    @EnvironmentObject var targetSettings: TargetSettings
    @Environment(\.date) var date
    @Environment(\.data) var data
    @Environment(\.viewingInterval) var viewingInterval
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
                if let sun = data?.sun {
                    Label(target.getVisibilityScore(at: location, viewingInterval: viewingInterval, sunData: sun, limitingAlt: targetSettings.limitingAltitude).percent(), systemImage: "eye")
                        .foregroundColor(.secondary)
                    Label(target.getSeasonScore(at: location, on: date, sunData: sun).percent(), systemImage: "calendar.circle")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

/**
 This View displays a horizontal scrolling section of different filter buttons.
 The filter buttons are explicity defined in an array.
 The array allows them to be sorted based on which ones are active.
 */
fileprivate struct FilterButtonMenu: View {
    @EnvironmentObject var viewModel: CatalogManager
    @Environment(\.data) var data
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
            if data != nil {
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
                    viewModel.refreshList(sunData: data?.sun)
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
    @EnvironmentObject var location: SavedLocation
    @Environment(\.date) var date
    @Environment(\.data) var data
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
                        viewModel.refreshList(sunData: data?.sun)
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
                viewModel.refreshList(sunData: data?.sun)
            }
            .presentationDetents([.fraction(0.5), .fraction(0.8)])
        }
    }
}

/**
 This view is for the modal that pops up on the Master Catalog to choose the date and location
 */
fileprivate struct CatalogViewSettings: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.data) var data
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    @Binding var date: Date
    @Binding var viewingInterval: DateInterval
    var body: some View {
        let locationBinding = Binding(
            get: { return locationList.first! },
            set: {
                for location in locationList { location.isSelected = false }
                $0.isSelected = true
                PersistenceManager.shared.saveData(context: context)
            }
        )
        VStack {
            DateSelector(date: $date)
                .padding()
                .font(.title2)
                .fontWeight(.semibold)
            Form {
                ConfigSection(header: "Viewing Interval") {
                    DateIntervalSelector(viewingInterval: $viewingInterval, customViewingInterval: viewingInterval != data?.sun.ATInterval, sun: data?.sun)
                }
                Picker("Location", selection: locationBinding) {
                    ForEach(locationList) { location in
                        Text(location.name!).tag(location)
                    }
                }
                .pickerStyle(.inline)
                .headerProminence(.increased)
            }
        }
    }
}

//struct Catalog_Previews: PreviewProvider {
//    static var previews: some View {
//        CatalogView()
//            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
//    }
//}
