//
//  CatalogList.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/13/23.
//

import SwiftUI

struct CatalogList: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    @FetchRequest(sortDescriptors: []) var reportSettings: FetchedResults<ReportSettings>
    let catalog: DSOCatalog
    var body: some View {
        List(DeepSkyTargetList.allTargets.filteredByCatalog([catalog]).sortedByCatalog(catalog: catalog).reversed()) { target in
            NavigationLink {
                DetailView(target: target)
                    .environmentObject(locationList.first!)
                    .environmentObject(reportSettings.first!)
            } label: {
                HStack {
                    Text("#\(target.designation.first(where: {$0.catalog == catalog})!.number)")
                    Divider()
                    Text(target.name.first!)
                }
            }
        }
    }
}
