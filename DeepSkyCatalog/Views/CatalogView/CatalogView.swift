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
    @StateObject var viewModel: CatalogViewModel
    @Binding var date: Date
    
    init(date: Binding<Date>, location: SavedLocation) {
        self._viewModel = StateObject(wrappedValue: CatalogViewModel(location: location, date: date.wrappedValue))
        self._date = date
    }
        
    var body: some View {
        // Only display targets if network data is available
        if let data = networkManager.data[.init(date: date, location: locationList.first!)] {
            NavigationStack() {
                SearchBar(viewModel: viewModel, updateAction: { viewModel.refreshList(sunData: data.sun) })
                FilterButtonMenu(viewModel: viewModel)
                
                List(viewModel.targets, id: \.id) { target in
                    NavigationLink(destination: DetailView(target: target)) {
                        VStack {
                            TargetCell(target: target)
                        }
                    }
                }
                .listStyle(.grouped)
                .toolbar() {
                    CatalogToolbar(viewModel: viewModel, date: $date)
                }
            }
            // Passing the date and location to use into all child views
            .environment(\.date, date)
            .environmentObject(locationList.first!)
            .environment(\.data, data)
            
            // Modals for editing each filter
            .filterModal(isPresented: $viewModel.isAllFilterModal, viewModel: viewModel) {
                EditAllFiltersView()
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
                viewModel.date = newDate
            }
            
            // When the location changes, make sure everything that depends on the date gets updated
            .onChange(of: locationList.first) { newLocation in
                viewModel.location = newLocation!
            }
        }

        // Otherwise show a loading icon
        else {
            VStack {
                ProgressView()
                Text("Fetching Data...")
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
    @Environment(\.date) var date
    @Environment(\.data) var data
    var target: DeepSkyTarget
    
    var body: some View {
        HStack {
            Image(target.image[0])
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 70)
                .cornerRadius(4)
            VStack(alignment: .leading) {
                Text(target.name[0])
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Label(target.getVisibilityScore(at: location, on: date, sunData: data.sun).percent(), systemImage: "eye")
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
    @ObservedObject var viewModel: CatalogViewModel
    init(viewModel: CatalogViewModel) {
        self.viewModel = viewModel
    }
    var body: some View {
        let buttons = [
            FilterButton(method: .catalog, viewModel: viewModel, active: !viewModel.catalogSelection.isEmpty, modal: $viewModel.isCatalogModal),
            FilterButton(method: .constellation, viewModel: viewModel, active: !viewModel.constellationSelection.isEmpty, modal: $viewModel.isConstellationModal),
            FilterButton(method: .type, viewModel: viewModel, active: !viewModel.typeSelection.isEmpty, modal: $viewModel.isTypeModal),
            FilterButton(method: .magnitude, viewModel: viewModel, active: !viewModel.dimmestMag.isNaN || !viewModel.brightestMag.isZero, modal: $viewModel.isMagModal),
            FilterButton(method: .size, viewModel: viewModel, active: !viewModel.minSize.isZero || !viewModel.maxSize.isNaN, modal: $viewModel.isSizeModal),
            FilterButton(method: .visibility, viewModel: viewModel, active: !viewModel.minVisScore.isZero, modal: $viewModel.isVisScoreModal),
            FilterButton(method: .meridian, viewModel: viewModel, active: !viewModel.minMerScore.isZero, modal: $viewModel.isMerScoreModal)
        ].sorted(by: {$0.active && !$1.active})
        
        ScrollView(.horizontal) {
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
                ForEach(buttons, id: \.method) { button in
                    button
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }
}

/**
 This View defines a singular filter button for a given filter method.
 */
private struct FilterButton: View {
    @ObservedObject var viewModel: CatalogViewModel
    @EnvironmentObject var location: SavedLocation
    @Environment(\.date) var date
    @Environment(\.data) var data
    let active: Bool
    @Binding var modalControl: Bool
    let method: FilterMethod
       
    init(method: FilterMethod, viewModel: CatalogViewModel, active: Bool, modal: Binding<Bool>) {
        self.viewModel = viewModel
        self.active = active
        self._modalControl = modal
        self.method = method
   }
    
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
    @ObservedObject var viewModel: CatalogViewModel
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    @Binding var date: Date
    @Environment(\.data) var data
    
    var body: some ToolbarContent {
        
        // Custom binding to select and get the selected location
        let locationBinding = Binding(
            get: { return locationList.first! },
            set: {
                for location in locationList { location.isSelected = false }
                $0.isSelected = true
            }
        )
        
        // The Location and Date selector on the left hand side
        ToolbarItemGroup(placement: .navigationBarLeading) {
            HStack() {
                Picker("Location", selection: locationBinding) {
                    ForEach(locationList) { location in
                        Text(location.name!).tag(location)
                    }
                }
                DateSelector(date: $date)
            }
        }
        
        // The Sort button on the right hand side
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 0) {
                Button() {
                    viewModel.sortDecending.toggle()
                    viewModel.targets.sort(by: viewModel.currentSort, sortDescending: viewModel.sortDecending, location: locationList.first!, date: date, sunData: data.sun)
                } label: {
                    Image(systemName: viewModel.sortDecending ? "chevron.up" : "chevron.down")
                }
                Menu(viewModel.currentSort.info.name) {
                    ForEach(SortMethod.allCases) { method in
                        SortButton(viewModel: viewModel, method: method)
                    }
                }
            }
        }
        
    }
}

/**
 This View is a Button that lies within the sort menu in the Master Catalog toolbar.
 */
private struct SortButton: View {
    @ObservedObject var viewModel: CatalogViewModel
    @EnvironmentObject var location: SavedLocation
    @Environment(\.date) var date
    @Environment(\.data) var data
    var method: SortMethod
    
    var body: some View {
        Button() {
            viewModel.targets.sort(by: method, sortDescending: viewModel.sortDecending, location: location, date: date, sunData: data.sun)
            viewModel.currentSort = method
        } label: {
            Label("By \(method.info.name)", systemImage: method.info.icon)
        }
    }
}

/**
 A Search Bar that binds its text to a given variable and executes a given action when text is submitted
 */
private struct SearchBar: View {
    @ObservedObject var viewModel: CatalogViewModel
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
