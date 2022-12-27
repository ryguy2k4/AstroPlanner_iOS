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
    @ObservedObject var viewModel: CatalogViewModel
    @Binding var date: Date
    
    init(date: Binding<Date>, location: SavedLocation) {
        self.viewModel = CatalogViewModel(location: location, date: date.wrappedValue)
        self._date = date
    }
        
    var body: some View {
        NavigationStack() {
            SearchBar(viewModel: viewModel, updateAction: {viewModel.refreshList()})
            FilterButtonMenu(viewModel: viewModel)
            // only display targets if network data is available
            if networkManager.isSafe {
                List(viewModel.targets, id: \.id) { target in
                    NavigationLink(destination: DetailView(target: target)) {
                        VStack {
                            TargetCell(date: $date, target: target)
                        }
                    }
                }
                .listStyle(.grouped)
                .toolbar() {
                    CatalogToolbar(viewModel: viewModel, date: $date)
                }
            }
            // otherwise show a loading icon
            else {
                VStack {
                    ProgressView()
                    Spacer()
                }
                .toolbar() {
                    CatalogToolbar(viewModel: viewModel, date: $date)
                }
            }
        }
        .environment(\.date, date)
        .environmentObject(locationList.first!)
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
            MagnitudeFilter(min: $viewModel.brightestMag, max: $viewModel.dimmestMag)
        }
        .filterModal(isPresented: $viewModel.isSizeModal, viewModel: viewModel) {
            SizeFilter(min: $viewModel.minSize, max: $viewModel.maxSize)
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
            Task {
                await networkManager.refreshAllData(at: viewModel.location, on: newDate)
                viewModel.date = newDate
            }
        }
    }
}

struct TargetCell: View {
    @EnvironmentObject var location: SavedLocation
    @Binding var date: Date

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
                Label(target.getVisibilityScore(at: location, on: date).percent(), systemImage: "eye")
                    .foregroundColor(.secondary)
                Label(target.getMeridianScore(at: location, on: date).percent(), systemImage: "arrow.right.and.line.vertical.and.arrow.left")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct CatalogToolbar: ToolbarContent {
    @ObservedObject var viewModel: CatalogViewModel
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    @Binding var date: Date
    
    var body: some ToolbarContent {
        let locationBinding = Binding(
            get: { return locationList.first! },
            set: {
                for location in locationList { location.isSelected = false }
                $0.isSelected = true
            }
        )
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
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 0) {
                Button() {
                    viewModel.sortDecending.toggle()
                    viewModel.targets.sort(by: viewModel.currentSort, sortDescending: viewModel.sortDecending, location: locationList.first!, date: date)
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

struct SortButton: View {
    @ObservedObject var viewModel: CatalogViewModel
    @EnvironmentObject var location: SavedLocation
    @Environment(\.date) var date: Date
    var method: SortMethod
    var body: some View {
        Button() {
            viewModel.targets.sort(by: method, sortDescending: viewModel.sortDecending, location: location, date: date)
            viewModel.currentSort = method
            
        } label: {
            Label("By \(method.info.name)", systemImage: method.info.icon)
        }
    }
}

struct SearchBar: View {
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

struct FilterButtonMenu: View {
    @ObservedObject var viewModel: CatalogViewModel
    var buttons: [FilterButton]
    init(viewModel: CatalogViewModel) {
        self.viewModel = viewModel
        // sort the buttons so that active ones show first
        buttons = [
            FilterButton(method: .catalog, viewModel: viewModel),
            FilterButton(method: .constellation, viewModel: viewModel),
            FilterButton(method: .type, viewModel: viewModel),
            FilterButton(method: .magnitude, viewModel: viewModel),
            FilterButton(method: .size, viewModel: viewModel),
            FilterButton(method: .visibility, viewModel: viewModel),
            FilterButton(method: .meridian, viewModel: viewModel)
        ].sorted(by: {$0.active && !$1.active})
    }
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(buttons, id: \.method) { button in
                    button
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }
}

struct FilterButton: View {
    @ObservedObject var viewModel: CatalogViewModel
    @EnvironmentObject var location: SavedLocation
    @Environment(\.date) var date
    let active: Bool
    let method: FilterMethod
    
       
    init(method: FilterMethod, viewModel: CatalogViewModel) {
        self.viewModel = viewModel
        self.method = method
        switch method {
        case .constellation:
            self.active = !viewModel.constellationSelection.isEmpty
        case .catalog:
            self.active = !viewModel.catalogSelection.isEmpty
        case .search:
            self.active = !viewModel.searchText.isEmpty
        case .type:
            self.active = !viewModel.typeSelection.isEmpty
        case .magnitude:
            self.active = !viewModel.brightestMag.isZero || !viewModel.dimmestMag.isNaN
        case .size:
            self.active = !viewModel.minSize.isZero || !viewModel.maxSize.isNaN
        case .visibility:
            self.active = !viewModel.minVisScore.isZero
        case .meridian:
            self.active = !viewModel.minMerScore.isZero
        }
   }
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: method.info.name.widthOfString(usingFont: UIFont.systemFont(ofSize: 20)) + 70, height: 30)
                .cornerRadius(13)
                .foregroundColor(Color(active ? "LightBlue" : "LightGray"))
            Button {
                switch method {
                case .catalog:
                    viewModel.isCatalogModal = true
                case .constellation:
                    viewModel.isConstellationModal = true
                case .type:
                    viewModel.isTypeModal = true
                case .magnitude:
                    viewModel.isMagModal = true
                case .size:
                    viewModel.isSizeModal = true
                case .visibility:
                    viewModel.isVisScoreModal = true
                case .meridian:
                    viewModel.isMerScoreModal = true
                default:
                    print()
                }
            } label: {
                HStack {
                    Label(method.info.name, systemImage: method.info.icon)
                        .foregroundColor(.primary)
                    Button {
                        viewModel.clearFilter(for: method)
                        viewModel.targets.sort(by: viewModel.currentSort, sortDescending: viewModel.sortDecending, location: location, date: date)
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

//struct Catalog_Previews: PreviewProvider {
//    static var previews: some View {
//        CatalogView()
//            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
//    }
//}
