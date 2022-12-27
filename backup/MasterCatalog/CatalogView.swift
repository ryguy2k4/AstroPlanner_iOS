//
//  CatalogView.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/6/22.
//

import SwiftUI

struct CatalogView: View {
    @EnvironmentObject var appConfig: AppConfig
    @StateObject private var viewModel = CatalogViewModel()
    @StateObject private var targets = DeepSkyTargetList()
    var body: some View {
        NavigationStack {
            SearchBar(viewModel: viewModel, updateAction: {viewModel.refreshList()})
            VStack {
                HStack {
                    FilterButton(method: .catalog, viewModel: viewModel) {
                        FilterCatalogView(viewModel: viewModel)
                    }
                    FilterButton(method: .constellation, viewModel: viewModel) {
                        FilterConstellationView(viewModel: viewModel)
                    }
                    FilterButton(method: .type, viewModel: viewModel) {
                        FilterTypeView(viewModel: viewModel)
                    }
                }
                HStack {
                    
                }
            }
            
            List(viewModel.targets, id: \.id) { target in
                NavigationLink(destination: DetailView(target: target)) {
                    TargetCell(appConfig: appConfig, target: target)
                }
            }
            .navigationTitle("Master Catalog ")
            .environmentObject(appConfig)
            .listStyle(.grouped)
            .toolbar() {
                CatalogToolbar(viewModel: viewModel, appConfig: appConfig)
            }
        }
        
    }
}

struct TargetCell: View {
    var appConfig: AppConfig
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
                Label("\(target.getVisibilityScore(with: appConfig).formatted(.percent.precision(.significantDigits(0...2))))", systemImage: "eye")
                    .foregroundColor(.secondary)
                Label("\(target.getMeridianScore(with: appConfig).formatted(.percent.precision(.significantDigits(0...2))))", systemImage: "arrow.right.and.line.vertical.and.arrow.left")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct CatalogToolbar: ToolbarContent {
    @ObservedObject var viewModel: CatalogViewModel
    var appConfig: AppConfig
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            HStack(spacing: 0) {
                Button(action: {
                    viewModel.sortDecending.toggle()
                    viewModel.sortTargets(by: viewModel.currentSort, with: appConfig)
                }, label: {
                    Image(systemName: viewModel.sortDecending ? "chevron.up" : "chevron.down")
                })
                Menu(viewModel.currentSort.info.name) {
                    ForEach(SortMethod.allCases) { method in
                        SortButton(viewModel: viewModel, appConfig: appConfig, sortType: method)
                    }
                }
            }
        }
    }
}

struct SortButton: View {
    @ObservedObject var viewModel: CatalogViewModel
    var appConfig: AppConfig
    var sortType: SortMethod
    var body: some View {
        Button(action: {
            viewModel.sortTargets(by: sortType, with: appConfig)
        }) {
            Label("By \(sortType.info.name)", systemImage: sortType.info.icon)
        }
    }
}

struct SearchBar: View {
    @ObservedObject var viewModel: CatalogViewModel
    var updateAction: () -> Void
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color("LightGray"))
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $viewModel.searchText)
                    .onSubmit(updateAction)
            }
            .foregroundColor(.black)
            .padding(.leading, 13)
        }
        .frame(height: 40)
        .cornerRadius(13)
        .padding()
    }
}

struct FilterButton <Content : View> : View {
    @ObservedObject var viewModel: CatalogViewModel
    let active: Bool
    let method: FilterMethod
    let destination: Content
    
       
    init(method: FilterMethod, viewModel: CatalogViewModel, @ViewBuilder destination: () -> Content) {
        self.viewModel = viewModel
        self.method = method
        self.destination = destination()
        self.active = {
            switch method {
            case .constellation:
                return !viewModel.constellationSelection.isEmpty
            case .catalog:
                return !viewModel.catalogSelection.isEmpty
            case .search:
                return !viewModel.searchText.isEmpty
            case .type:
                return !viewModel.typeSelection.isEmpty
            }
        }()
   }
    
    var body: some View {
        ZStack {
            if active {
                Rectangle()
                    .frame(width: method.info.name.widthOfString(usingFont: UIFont.systemFont(ofSize: 20)) + 45, height: 25)
                    .cornerRadius(13)
                    .foregroundColor(Color("LightBlue"))
                HStack {
                    Button(action: {
                        viewModel.clearFilter(for: method)
                    }, label: {
                        Image(systemName: "x.circle")
                    })
                    NavigationLink(destination: destination) {
                        Text(method.info.name)
                            .foregroundColor(.primary)
                    }
                }
            } else {
                Rectangle()
                    .frame(width: method.info.name.widthOfString(usingFont: UIFont.systemFont(ofSize: 20)) + 45, height: 25)
                    .cornerRadius(13)
                    .foregroundColor(Color("LightGray"))
                NavigationLink(destination: destination) {
                    Label(method.info.name, systemImage: method.info.icon)
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

struct Catalog_Previews: PreviewProvider {
    static var previews: some View {
        CatalogView()
            .environmentObject(ConfigTest.appConfig)
    }
}
