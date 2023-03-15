//
//  PersistenceManager.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/13/22.
//

import CoreData

final class PersistenceManager: ObservableObject {
    
    static let shared = PersistenceManager()
        
    /// The location of the old CoreData store before moving it to the AppGroup
    var oldStoreURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return directory.appending(component: "DeepSkyCatalog.sqlite")
    }
    
    /// The location of the new CoreData store within the AppGroup
    var sharedStoreURL: URL {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.ryansponzilli.DeepSkyCatalog")
        return container!.appending(component: "DeepSkyCatalog.sqlite")
    }
    
    let container: NSPersistentCloudKitContainer
    
    private init() {
        container = NSPersistentCloudKitContainer(name: "DeepSkyCatalog")
        container.persistentStoreDescriptions.first!.url = sharedStoreURL
        container.persistentStoreDescriptions.first!.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.DeepSkyCatalog")
        container.loadPersistentStores() { description, error in
            if let error = error {
                fatalError("Failed to load data: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // if there are no report settings stored, then create one
        if let count = try? self.container.viewContext.count(for: ReportSettings.fetchRequest()), count == 0 {
            _ = ReportSettings(context: self.container.viewContext)
        }
        
        // if there are no target settings stored, then create one
        if let count = try? self.container.viewContext.count(for: TargetSettings.fetchRequest()), count == 0 {
            _ = TargetSettings(context: self.container.viewContext)
        }
        
        // clean up legacy old store
        do {
            try FileManager.default.removeItem(at: oldStoreURL)
            print("old store deleted successfully")
        } catch {
            print("unable to delete old store")
        }
        
        // clean up legacy default preset
        if let defaultPreset = (try? self.container.viewContext.fetch(ImagingPreset.fetchRequest()))?.first(where: {$0.name == "Default"}) {
            self.container.viewContext.delete(defaultPreset)
            saveData(context: container.viewContext)
        }
    }
    
    func saveData(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("Data Saved")
        } catch {
            fatalError("Error saving data: \(error.localizedDescription)")
        }
    }
    
    func addLocation(name: String, latitude: Double, longitude: Double, timezone: String, isSelected: Bool = false, context: NSManagedObjectContext) {
        let location = SavedLocation(context: context)
        location.name = name
        location.latitude = latitude
        location.longitude = longitude
        location.timezone = timezone
        location.isSelected = isSelected
        saveData(context: context)
    }
    
    func editLocation(location: SavedLocation, name: String? = nil, latitude: Double? = nil, longitude: Double? = nil, timezone: String? = nil, context: NSManagedObjectContext) {
        if let name = name {
            location.name = name
        }
        if let latitude = latitude {
            location.latitude = latitude
        }
        if let longitude = longitude {
            location.longitude = longitude
        }
        if let timezone = timezone {
            location.timezone = timezone
        }
        saveData(context: context)
    }
    
    func addImagingPreset(name: String, focalLength: Double, pixelSize: Double, resLength: Int16, resWidth: Int16, isSelected: Bool = false, context: NSManagedObjectContext) {
        let preset = ImagingPreset(context: context)
        preset.name = name
        preset.isSelected = isSelected
        preset.focalLength = focalLength
        preset.pixelSize = pixelSize
        preset.resolutionLength = resLength
        preset.resolutionWidth = resWidth
        saveData(context: context)
    }
    
    func editImagingPreset(preset: ImagingPreset, name: String? = nil, focalLength: Double? = nil, pixelSize: Double? = nil, resLength: Int16? = nil, resWidth: Int16? = nil, context: NSManagedObjectContext) {
        if let name = name {
            preset.name = name
        }
        if let focalLength = focalLength {
            preset.focalLength = focalLength
        }
        if let pixelSize = pixelSize {
            preset.pixelSize = pixelSize
        }
        if let resLength = resLength {
            preset.resolutionLength = resLength
        }
        if let resWidth = resWidth {
            preset.resolutionWidth = resWidth
        }
        saveData(context: context)
        
    }
}
