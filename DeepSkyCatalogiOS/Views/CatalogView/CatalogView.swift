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
    @Binding var date: Date
    @Binding var viewingInterval: DateInterval
    
    @State private var isSettingsModal = false
        
    var body: some View {
        let location: Location? = {
            if let selected = locationList.first(where: { $0.isSelected == true }) {
                // try to find a selected location
                return Location(saved: selected)
            } else if locationManager.locationEnabled, let latest = locationManager.latestLocation {
                // try to get the current location
                return Location(current: latest)
            } else if let any = locationList.first {
                // try to find any location
                any.isSelected = true
                return Location(saved: any)
            } else {
                // no location found
                return nil
            }
        }()
        
        if let location = location {
            let data = networkManager.data[.init(date: date, location: location)]
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
            .searchable(text: $catalogManager.searchText)
            .onSubmit(of: .search) {
                catalogManager.refreshList(date: date, viewingInterval: viewingInterval, location: location, targetSettings: targetSettings.first!, sunData: data?.sun)
            }
            .onChange(of: catalogManager.searchText) { newValue in
                if newValue.isEmpty {
                    catalogManager.refreshList(date: date, viewingInterval: viewingInterval, location: location, targetSettings: targetSettings.first!, sunData: data?.sun)
                }
            }
            .searchSuggestions {
                // grab top 15 search results
                let suggestions = DeepSkyTargetList.objects.filteredBySearch(catalogManager.searchText)
                
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
                CatalogSettingsModal(date: $date, viewingInterval: $viewingInterval)
                    .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
                    .disabled(data == nil)
            }
            
            // Passing the date and location to use into all child views
            .environment(\.date, date)
            .environment(\.location, location)
            .environmentObject(targetSettings.first!)
            .environmentObject(catalogManager)
            .environment(\.data, data)
        }
        
        // if there is no location stored, then prompt the user to create one
        else {
            NavigationStack {
                VStack {
                    Text("Add a Location")
                        .fontWeight(.semibold)
                    NavigationLink(destination: LocationSettings()) {
                        Label("Locations Settings", systemImage: "location")
                    }
                    .padding()
                }
            }
        }
    }
}

/**
 This View displays information about the target at a glance. It is used within the Master Catalog list.
 */
fileprivate struct TargetCell: View {
    @Environment(\.location) var location: Location
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

//struct Catalog_Previews: PreviewProvider {
//    static var previews: some View {
//        CatalogView()
//            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
//    }
//}
