//
//  NetworkManager.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/11/22.
//

import Foundation

final class NetworkManager: ObservableObject {
    
    static var shared = NetworkManager()
    
    struct DataKey: Hashable {
        let date: Date
        let location: SavedLocation
    }
    
    @Published var data: [DataKey : (sun: SunData, moon: MoonData)] = [:]
    
    private init() { }
    
    @MainActor
    func getData(at location: SavedLocation, on date: Date) async throws {
        do {
            async let decodedMoonDataToday: RawMoonData = try fetchTask(
                from: "https://aa.usno.navy.mil/api/rstt/oneday?date=\(date.formatted(format: "YYYY-MM-dd"))&coords=\(location.latitude),\(location.longitude)&tz=\(location.timezone)")
            async let decodedMoonDataTomorrow: RawMoonData = try fetchTask(
                from: "https://aa.usno.navy.mil/api/rstt/oneday?date=\(date.tomorrow().formatted(format: "YYYY-MM-dd"))&coords=\(location.latitude),\(location.longitude)&tz=\(location.timezone)")
            async let decodedSunDataToday: RawSunData = try fetchTask(
                from: "https://api.sunrise-sunset.org/json?lat=\(location.latitude)&lng=\(location.longitude)&date=\(date.formatted(format: "YYYY-MM-dd"))&formatted=0")
            async let decodedSunDataTomorrow: RawSunData = try fetchTask(
                from: "https://api.sunrise-sunset.org/json?lat=\(location.latitude)&lng=\(location.longitude)&date=\(date.tomorrow().formatted(format: "YYYY-MM-dd"))&formatted=0")
            
            let sunToday = SunData(dataToday: try await decodedSunDataToday, dataTomorrow: try await decodedSunDataTomorrow)
            let moonToday = MoonData(dataToday: try await decodedMoonDataToday, dataTomorrow: try await decodedMoonDataTomorrow, on: date, sun: sunToday)
            self.data[.init(date: date, location: location)] = (sunToday, moonToday)
            print("API Data Fetched")
        } catch FetchError.unableToFetch {
            print("Error: No Internet Connection")
            throw FetchError.unableToFetch
        } catch FetchError.unableToDecode {
            print("Error: unable to decode data")
        } catch FetchError.unableToMakeURL {
            print("Error: Bad URL")
        } catch {
            print("Unknown Error: \(error.localizedDescription)")
        }
    }
    
    func getImageData(for dateString: String) async throws -> APODImageData {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        guard let date = dateFormatter.date(from: dateString) else {
            throw FetchError.unableToMakeURL
        }
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: date)
        let apiKey = "merZmUVAd6yZ8cKS2YRcohhygVOEeIAn1WhRBVSy"
        let url = "https://api.nasa.gov/planetary/apod?api_key=\(apiKey)&date=\(formattedDate)"
        return try await fetchTask(from: url)
    }
    
    /**
     A generic function that fetches API data from a given URL for a Decodable Type
     - Parameter from: The URL to fetch from
     - Returns: The retrieved and decoded data
     - Throws: A FetchError
     */
    private func fetchTask<T: Decodable>(from urlString: String) async throws -> T {
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

struct APODImageData: Codable {
    let copyright: String?
    let explanation: String
    let url: String
    let hdurl: String
    let title: String
    let date: String
}
