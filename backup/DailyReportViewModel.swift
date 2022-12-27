//
//  DailyReportViewModel.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/27/22.
//

import Foundation

extension DailyReportView {
    final class DailyReportViewModel: ObservableObject {
        @Published var targets = DeepSkyTargetList.allTargets
        
        func getReport(with appConfig: AppConfig) {
            let moon = appConfig.sun?.ATInterval.intersection(with: appConfig.moon!.moonInterval)
            
            // if moon is not a problem
            if moon == nil || moon!.duration < appConfig.sun!.ATInterval.duration / 3 {
                filterByType(typeSelection: [.galaxy, .darkNebula, .globularStarCluster, .openStarCluster, .galaxyGroup, .reflectionNebula, .planetaryNebula])
                sortTargets(by: .visibility, with: appConfig)
                targets.removeLast(targets.count-3)
            } else {
                filterByType(typeSelection: [.emissionNebula, .supernovaRemnant])
                sortTargets(by: .visibility, with: appConfig)
                targets.removeLast(targets.count-3)
            }
            
            
        }
        
        private func sortTargets(by method: SortMethod, with appConfig: AppConfig) {
            var sortedTargets = targets
            switch method {
            case .visibility:
                sortedTargets.sort(by: {$0.getVisibilityScore(with: appConfig) > $1.getVisibilityScore(with: appConfig)})
            case .meridian:
                sortedTargets.sort(by: {$0.getMeridianScore(with: appConfig) > $1.getMeridianScore(with: appConfig)})
            case .dec:
                sortedTargets.sort(by: {$0.dec > $1.dec})
            case .ra:
                sortedTargets.sort(by: {$0.ra > $1.ra})
            }
            targets = sortedTargets
        }
        
        private func filterByType(typeSelection: [DSOType]) {
            targets = targets.filter() {
                var containsThis = false
                for type in typeSelection {
                    for item in $0.type where !containsThis {
                        containsThis = (item == type)
                    }
                }
                return containsThis
            }
        }
    }
}
