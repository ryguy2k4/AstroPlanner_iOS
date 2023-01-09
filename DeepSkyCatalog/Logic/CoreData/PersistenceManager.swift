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
    }
}
