//
//  NetworkManager.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/11/22.
//

import Foundation

final class NetworkManager: ObservableObject {
    
    static var shared = NetworkManager()
    
    var sun: SunData?
    var moon: MoonData?
    var currentDate: Date?
    @Published var isSafe = false
    
    private init() { }
    
    @MainActor
    func refreshAllData(at location: SavedLocation, on date: Date) async {
        do {
            isSafe = false
            async let sunToday = try NetworkManager.fetchSunData(at: location, on: date)
            async let moonToday = try NetworkManager.fetchMoonData(at: location, on: date)
            
            try self.sun = await sunToday
            try self.moon = await moonToday
            currentDate = date
            isSafe = true
            print("API Data Refreshed.")
        } catch FetchError.unableToFetch {
            print("No Internet Connection.")
        } catch FetchError.unableToDecode {
            print("Something went wrong, unable to decode data.")
        } catch FetchError.unableToMakeURL {
            print("Error: Bad URL")
        } catch {
            print("Unknown Error: \(error.localizedDescription)")
        }
    }
    
    private static func fetchSunData(at location: SavedLocation, on date: Date) async throws -> SunData {
        let decodedDataToday: RawSunData = try await fetchTask(
            from: "https://api.sunrise-sunset.org/json?lat=\(location.latitude)&lng=\(location.longitude)&date=\(date.formatted(format: "YYYY-MM-dd"))&formatted=0")
        let decodedDataTomorrow: RawSunData = try await fetchTask(
            from: "https://api.sunrise-sunset.org/json?lat=\(location.latitude)&lng=\(location.longitude)&date=\(date.tomorrow().formatted(format: "YYYY-MM-dd"))&formatted=0")
        
        return SunData(from: decodedDataToday, and: decodedDataTomorrow)
    }
    
    private static func fetchMoonData(at location: SavedLocation, on date: Date) async throws -> MoonData {
        // add in timezone stuff
        let decodedDataToday: RawMoonData = try await fetchTask(
            from: "https://aa.usno.navy.mil/api/rstt/oneday?date=\(date.formatted(format: "YYYY-MM-dd"))&coords=\(location.latitude),\(location.longitude)&tz=\(location.timezone)")
        let decodedDataTomorrow: RawMoonData = try await fetchTask(
            from: "https://aa.usno.navy.mil/api/rstt/oneday?date=\(date.tomorrow().formatted(format: "YYYY-MM-dd"))&coords=\(location.latitude),\(location.longitude)&tz=\(location.timezone)")
        let sunData = try await fetchSunData(at: location, on: date)
                
        return MoonData(from: decodedDataToday, and: decodedDataTomorrow, on: date, sun: sunData)
    }
    
    /**
     A generic function that fetches API data from a given URL for a Decodable Type
     - Parameter from: The URL to fetch from
     - Returns: The retrieved and decoded data
     - Throws: A FetchError
     */
    private static func fetchTask<T: Decodable>(from urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw FetchError.unableToMakeURL
        }
        guard let (data, _) = try? await URLSession.shared.data(from: url) else {
            throw FetchError.unableToFetch
        }
        guard let decodedData = try? JSONDecoder().decode(T.self, from: data ) else {
            throw FetchError.unableToDecode
        }
        return decodedData
    }
}
