//
//  CatalogList.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/13/23.
//

import SwiftUI

struct CatalogList: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    @FetchRequest(sortDescriptors: []) var targetSettings: FetchedResults<TargetSettings>
    @Environment(\.date) var date
    @EnvironmentObject var networkManager: NetworkManager
    let catalog: TargetCatalog
    var body: some View {
        let data = networkManager.data[.init(date: date, location: locationList.first!)]
        List(DeepSkyTargetList.allTargets.filteredByCatalog([catalog]).sortedByCatalog(catalog: catalog).reversed()) { target in
            NavigationLink {
                DetailView(target: target)
                    .environmentObject(locationList.first!)
                    .environmentObject(targetSettings.first!)
                    .environment(\.data, data)
            } label: {
                HStack {
                    Text("#\(target.designation.first(where: {$0.catalog == catalog})!.number)")
                    Divider()
                    Text(target.name?.first! ?? target.defaultName)
                }
            }
        }
    }
}
