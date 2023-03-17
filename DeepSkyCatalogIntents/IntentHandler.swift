//
//  IntentHandler.swift
//  DeepSkyCatalogIntents
//
//  Created by Ryan Sponzilli on 3/12/23.
//

import Intents
import CoreData

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}

extension IntentHandler: ReportListIntentHandling {
    func provideLocationOptionsCollection(for intent: ReportListIntent) async throws -> INObjectCollection<NSString> {
        var locationsFetchRequest: NSFetchRequest<SavedLocation> {
            let request = SavedLocation.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(SortDescriptor(\SavedLocation.isSelected, order: .reverse)), NSSortDescriptor(SortDescriptor(\SavedLocation.name, order: .forward))]
            return request
        }
        
        let locations = try PersistenceManager.shared.container.viewContext.fetch(locationsFetchRequest).map({$0.name!})
                
        return INObjectCollection(items: locations as [NSString])
    }
    
    func defaultLocation(for intent: ReportListIntent) -> String? {
        var locationsFetchRequest: NSFetchRequest<SavedLocation> {
            let request = SavedLocation.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(SortDescriptor(\SavedLocation.isSelected, order: .reverse)), NSSortDescriptor(SortDescriptor(\SavedLocation.name, order: .forward))]
            return request
        }
        
        let locations = try? PersistenceManager.shared.container.viewContext.fetch(locationsFetchRequest)
        
        return locations?.first?.name
    }
}
