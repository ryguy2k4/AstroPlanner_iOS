////
////  NetworkManager.swift
////  Deep Sky Catalog
////
////  Created by Ryan Sponzilli on 11/11/22.
////
//
//import Foundation
//
//final class NetworkManager: ObservableObject {
//    
//    static var shared = NetworkManager()
//    
//    private init() { }
//    
//    func getImageData(for dateString: String) async throws -> APODImageData {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyMMdd"
//        guard let date = dateFormatter.date(from: dateString) else {
//            throw FetchError.unableToMakeURL
//        }
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let formattedDate = dateFormatter.string(from: date)
//        let apiKey = "merZmUVAd6yZ8cKS2YRcohhygVOEeIAn1WhRBVSy"
//        let url = "https://api.nasa.gov/planetary/apod?api_key=\(apiKey)&date=\(formattedDate)"
//        return try await fetchTask(from: url)
//    }
//    
//    /**
//     A generic function that fetches API data from a given URL for a Decodable Type
//     - Parameter from: The URL to fetch from
//     - Returns: The retrieved and decoded data
//     - Throws: A FetchError
//     */
//    func fetchTask<T: Decodable>(from urlString: String) async throws -> T {
//        guard let url = URL(string: urlString) else {
//            throw FetchError.unableToMakeURL
//        }
//        guard let (data, _) = try? await URLSession.shared.data(from: url) else {
//            throw FetchError.unableToFetch
//        }
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .iso8601
//        guard let decodedData = try? decoder.decode(T.self, from: data ) else {
//            throw FetchError.unableToDecode
//        }
//        return decodedData
//    }
//}
//
//struct APODImageData: Codable {
//    let copyright: String?
//    let explanation: String
//    let url: String
//    let hdurl: String
//    let title: String
//    let date: String
//}
