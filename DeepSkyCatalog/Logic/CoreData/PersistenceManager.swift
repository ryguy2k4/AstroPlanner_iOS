//
//  PersistenceManager.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/13/22.
//

import CoreData

final class PersistenceManager: ObservableObject {
    
    static let shared = PersistenceManager()
    
    let container = NSPersistentContainer(name: "DeepSkyCatalog")
    
    private init() {
        container.loadPersistentStores() { description, error in
            if let error = error {
                print("Failed to load data: \(error.localizedDescription)")
            }
            
            // if there are no locations stored, then create one
            if let count = try? self.container.viewContext.count(for: NSFetchRequest(entityName: "SavedLocation")) {
                if count == 0 {
                    self.addLocation(name: "Chicago", latitude: 41.833, longitude: -87.872, timezone: -6, isSelected: true, context: self.container.viewContext)
                }
            }
            
            // if there are no imaging presets stored, then create one
            if let count = try? self.container.viewContext.count(for: NSFetchRequest(entityName: "ImagingPreset")) {
                if count == 0 {
                    self.addImagingPreset(name: "Default", focalLength: 360, pixelSize: 3.76, resLength: 6216, resWidth: 4153, isSelected: true, context: self.container.viewContext)
                }
            }
            
            // if there are no report settings stored, then create one
            if let count = try? self.container.viewContext.count(for: NSFetchRequest(entityName: "ReportSettings")) {
                if count == 0 {
                    let settings = ReportSettings(context: self.container.viewContext)
                    settings.brightestMag = 0
                    settings.dimmestMag = .nan
                    settings.maxAllowedMoon = 0.2
                    settings.limitingAltitude = 0
                }
            }
        }
    }
    
    func saveData(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("Data Saved")
        } catch {
            print("Error saving data")
        }
    }
    
    func addLocation(name: String, latitude: Double, longitude: Double, timezone: Int16, isSelected: Bool = false, context: NSManagedObjectContext) {
        let location = SavedLocation(context: context)
        location.name = name
        location.latitude = latitude
        location.longitude = longitude
        location.timezone = timezone
        location.isSelected = isSelected
        saveData(context: context)
    }
    
    func editLocation(location: SavedLocation, name: String? = nil, latitude: Double? = nil, longitude: Double? = nil, timezone: Int16? = nil, context: NSManagedObjectContext) {
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
        preset.pixelScale =  pixelSize / focalLength * 206.2648
        preset.fovLength = preset.pixelScale * Double(preset.resolutionLength) / 60
        preset.fovWidth = preset.pixelScale * Double(preset.resolutionWidth) / 60
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
        preset.pixelScale = preset.pixelSize / preset.focalLength * 206.2648
        preset.fovLength = preset.pixelScale * Double(preset.resolutionLength) / 60
        preset.fovWidth = preset.pixelScale * Double(preset.resolutionWidth) / 60
        saveData(context: context)
        
    }
}
