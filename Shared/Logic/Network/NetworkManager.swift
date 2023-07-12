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
        
        init(date: Date, location: Location) {
            self.date = date
            self.location = location
        }
    }
    
    @Published var sun: [DataKey : SunData] = [:]
    
    private init() { }
        
    func updateSunData(at location: Location, on date: Date) async throws -> [DataKey : SunData] {
        //print("UPDATE")
        
        guard !sun.contains(where: {$0.key == DataKey(date: date, location: location)}) else {
            return [:]
        }
        
        // Try WeatherKit
        let date = date.startOfLocalDay(timezone: location.timezone)
        do {
            let extendedCondition = !sun.keys.contains(where: {$0.location == location})
            let endDate: Date? = extendedCondition && date == Date.now.startOfLocalDay(timezone: location.timezone) ? date.addingTimeInterval(86400*9) : nil
            return try await getWeatherKitData(location: location, date: date, endDate: endDate)
        }
        // Fallback on APIs
        catch {
            //print("WeatherKit Error: \(error.localizedDescription)")
            //print("Falling back on APIs")
            do {
                return [DataKey(date: date, location: location) : try await getAPIData(at: location, on: date)]
            } catch FetchError.unableToFetch {
                //print("Error: No Internet Connection")
                throw FetchError.unableToFetch
            } catch FetchError.unableToDecode {
                //print("Error: unable to decode data")
                return [:]
            } catch FetchError.unableToMakeURL {
                //print("Error: Bad URL")
                return [:]
            } catch {
                //print("Unknown Error: \(error.localizedDescription)")
                return [:]
            }
        }
    }
    
    func getWeatherKitData(location: Location, date: Date, endDate: Date? = nil) async throws -> [DataKey : SunData] {
        guard date >= .weatherKitHistoricalLimit && date <= .now.startOfLocalDay(timezone: location.timezone).addingTimeInterval(86400*8) else {
            throw FetchError.dateOutOfRange
        }
        
        let forecast = try await WeatherService().weather(for: location.clLocation, including: .daily(startDate: date, endDate: endDate?.tomorrow() ?? date.tomorrow().tomorrow())).forecast
        
        // Make sure WeatherKit returned data
        guard !forecast.isEmpty else {
            throw FetchError.weatherKitNoData
        }
        
        var forecastDate = date
        var array: [DataKey : SunData] = [:]
        for index in forecast.indices.dropLast() {
            //print(forecastDate.formatted(format: "yyyy-MM-dd HH:mm:ss Z", timezone: location.timezone))
            let dataKey = DataKey(date: forecastDate, location: location)
            array[dataKey] = SunData(sunEventsToday: forecast[index].sun, sunEventsTomorrow: forecast[index+1].sun)
            forecastDate = forecastDate.tomorrow()
        }

        //print("WeatherKit Data Fetched for \(array.count) day(s)")
        return array
            
    }
    
    func getAPIData(at location: Location, on date: Date) async throws -> SunData {
        do {
            async let decodedSunDataToday: RawSunData = try fetchTask(from: "https://api.sunrise-sunset.org/json?lat=\(location.latitude)&lng=\(location.longitude)&date=\(date.formatted(format: "YYYY-MM-dd"))&formatted=0")
            async let decodedSunDataTomorrow: RawSunData = try fetchTask(from: "https://api.sunrise-sunset.org/json?lat=\(location.latitude)&lng=\(location.longitude)&date=\(date.tomorrow().formatted(format: "YYYY-MM-dd"))&formatted=0")
            
            let sunToday = SunData(dataToday: try await decodedSunDataToday, dataTomorrow: try await decodedSunDataTomorrow)
            
            //print("API Data Fetched")
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
