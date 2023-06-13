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
    @EnvironmentObject var locationManager: LocationManager
    @StateObject private var catalogManager: CatalogManager = CatalogManager()
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    @FetchRequest(sortDescriptors: []) var targetSettings: FetchedResults<TargetSettings>
    
    @Environment(\.location) var location
    @Environment(\.sunData) var sunData
    @Binding var date: Date
    @State var pickerDate: Date = .now
    @Binding var viewingInterval: DateInterval
    
    @State private var isLocationModal = false
    @State private var isDateModal = false
        
    init(date: Binding<Date>, viewingInterval: Binding<DateInterval>) {
        self._date = date
        self._viewingInterval = viewingInterval
        self.pickerDate = date.wrappedValue
    }
    var body: some View {
        NavigationStack() {
            FilterButtonMenu(date: $date)
            
            List(catalogManager.targets, id: \.id) { target in
                NavigationLink(destination: DetailView(target: target)) {
                    VStack {
                        TargetCell(target: target)
                    }
                }
            }
            .listStyle(.grouped)
            .toolbar() {
                ToolbarLogo()
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isDateModal = true
                    } label: {
                        Image(systemName: "calendar")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isLocationModal = true
                    } label: {
                        Image(systemName: "location")
                    }
                }
            }
        }
        
        // Modifiers to enable searching
        .searchable(text: $catalogManager.searchText)
        .onSubmit(of: .search) {
            catalogManager.refreshList(date: date, viewingInterval: viewingInterval, location: location, targetSettings: targetSettings.first!, sunData: sunData)
        }
        .onChange(of: catalogManager.searchText) { newValue in
            if newValue.isEmpty {
                catalogManager.refreshList(date: date, viewingInterval: viewingInterval, location: location, targetSettings: targetSettings.first!, sunData: sunData)
            }
        }
        .searchSuggestions {
            // grab top 15 search results
            let suggestions = DeepSkyTargetList.whitelistedTargets.filteredBySearch(catalogManager.searchText)
            
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
        .sheet(isPresented: $isDateModal){
            ViewingIntervalModal(date: $pickerDate, viewingInterval: $viewingInterval)
                .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
        }
        .sheet(isPresented: $isLocationModal){
            LocationPickerModal()
                .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
        }
        .onChange(of: isDateModal, perform: { newValue in
            if newValue == false {
                date = pickerDate
            }
        })
        
        // Passing the date and location to use into all child views
        .environment(\.date, date)
        .environment(\.location, location)
        .environmentObject(targetSettings.first!)
        .environmentObject(catalogManager)
        .environment(\.sunData, sunData)
        .environment(\.viewingInterval, viewingInterval)
    }
}

/**
 This View displays information about the target at a glance. It is used within the Master Catalog list.
 */
fileprivate struct TargetCell: View {
    @Environment(\.location) var location: Location
    @EnvironmentObject var targetSettings: TargetSettings
    @Environment(\.date) var date
    @Environment(\.sunData) var sunData
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
                Label(target.getVisibilityScore(at: location, viewingInterval: viewingInterval, sunData: sunData, limitingAlt: targetSettings.limitingAltitude).percent(), systemImage: "eye")
                    .foregroundColor(.secondary)
                Label(target.getSeasonScore(at: location, on: date, sunData: sunData).percent(), systemImage: "calendar.circle")
                    .foregroundColor(.secondary)
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
