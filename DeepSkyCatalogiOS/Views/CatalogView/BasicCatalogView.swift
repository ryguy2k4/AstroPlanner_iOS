//
//  BasicCatalogView.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 3/31/23.
//

import SwiftUI

struct BasicCatalogView: View {
    @Environment(\.dismissSearch) private var dismissSearch
    @Environment(\.isSearching) private var isSearching
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var locationManager: LocationManager
    @StateObject private var catalogManager: CatalogManager = CatalogManager()
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    @FetchRequest(sortDescriptors: []) var targetSettings: FetchedResults<TargetSettings>
    
    @EnvironmentObject var store: HomeViewModel
    
    @State private var isLocationModal = false
    @State private var isDateModal = false
        
    var body: some View {
        NavigationStack() {
            
            List(catalogManager.targets, id: \.id) { target in
                NavigationLink(destination: BasicDetailView(target: target)) {
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
            catalogManager.refreshList(date: store.date, viewingInterval: nil, location: store.location, targetSettings: targetSettings.first!, sunData: nil)
        }
        .onChange(of: catalogManager.searchText) { newValue in
            if newValue.isEmpty {
                catalogManager.refreshList(date: store.date, viewingInterval: nil, location: store.location, targetSettings: targetSettings.first!, sunData: nil)
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
            DateSelector()
                .padding()
                .font(.title2)
                .fontWeight(.semibold)
                .environmentObject(store)
                .presentationDetents([.fraction(0.1), .fraction(0.2), .fraction(0.3)])
        }
        .sheet(isPresented: $isLocationModal){
            LocationPickerModal()
                .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
        }
        
        .environmentObject(catalogManager)
    }
}

/**
 This View displays information about the target at a glance. It is used within the Master Catalog list.
 */
fileprivate struct TargetCell: View {
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
            }
        }
    }
}

//struct BasicCatalogView_Previews: PreviewProvider {
//    static var previews: some View {
//        BasicCatalogView()
//    }
//}
