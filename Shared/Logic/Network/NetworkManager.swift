//
//  NetworkManager.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/11/22.
//

import Foundation
import WeatherKit

final class NetworkManager: ObservableObject {
    
    static var shared = NetworkManager()
    
    struct DataKey: Hashable {
        let date: Date
        let location: Location
    }
    
    @Published var sun: [DataKey : SunData] = [:]
    
    private init() { }
        
    @MainActor
    func updateSunData(at location: Location, on date: Date) async throws {
        // Try WeatherKit
        do {
            let data = try await getWeatherKitData(location: location, date: self.sun.isEmpty ? date.yesterday() : date, endDate: self.sun.isEmpty ? date.addingTimeInterval(86_400*9) : nil)
            // merge the new data, overwriting if necessary
            self.sun.merge(data) { _, new in new }
            print("Data Updated from WeatherKit")
            
        }
        // Fallback on APIs
        catch {
            print("WeatherKit Error: \(error.localizedDescription)")
            print("Falling back on APIs")
            do {
                self.sun[DataKey(date: date, location: location)] = try await getAPIData(at: location, on: date)
                print("Data Updated from APIs")
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

    }
    
    func getWeatherKitData(location: Location, date: Date, endDate: Date? = nil) async throws -> [DataKey : SunData] {
        guard date >= .now.startOfDay().yesterday() && date <= .now.startOfDay().addingTimeInterval(86400*8) else {
            throw FetchError.dateOutOfRange
        }
        
        let forecast = try await WeatherService().weather(for: location.clLocation, including: .daily(startDate: date, endDate: endDate?.tomorrow() ?? date.tomorrow())).forecast
        
        // Make sure WeatherKit returned data
        guard !forecast.isEmpty else {
            throw FetchError.weatherKitNoData
        }
        
        var array: [DataKey : SunData] = [:]
        for index in forecast.indices.dropLast() {
            let dataKey = DataKey(date: forecast[index].date, location: location)
            array[dataKey] = SunData(sunEventsToday: forecast[index].sun, sunEventsTomorrow: forecast[index+1].sun)
        }

        print("WeatherKit Data Fetched")
        return array
            
    }
    
    func getAPIData(at location: Location, on date: Date) async throws -> SunData {
        do {
            let timezoneOffset = location.timezone.secondsFromGMT() / 3600
            async let decodedSunDataToday: RawSunData = try fetchTask(from: "https://api.sunrise-sunset.org/json?lat=\(location.latitude)&lng=\(location.longitude)&date=\(date.formatted(format: "YYYY-MM-dd"))&formatted=0")
            async let decodedSunDataTomorrow: RawSunData = try fetchTask(from: "https://api.sunrise-sunset.org/json?lat=\(location.latitude)&lng=\(location.longitude)&date=\(date.tomorrow().formatted(format: "YYYY-MM-dd"))&formatted=0")
            
            let sunToday = SunData(dataToday: try await decodedSunDataToday, dataTomorrow: try await decodedSunDataTomorrow)
            
            print("API Data Fetched")
            return sunToday
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
