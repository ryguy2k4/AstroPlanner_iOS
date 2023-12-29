////
////  FetchError.swift
////  DeepSkyCatalog
////
////  Created by Ryan Sponzilli on 11/15/22.
////
//
//import Foundation
//
//enum FetchError: Error {
//    case unableToFetch
//    case unableToDecode
//    case unableToMakeURL
//    case dateOutOfRange
//    case weatherKitNoData
//    
//    var localizedDescription: String {
//        switch self {
//        case .unableToFetch:
//            return "Unable to Fetch from the API"
//        case .unableToDecode:
//            return "The data was fetched, but couldn't be decoded"
//        case .unableToMakeURL:
//            return "Something went wrong synthesizing the URL"
//        case .dateOutOfRange:
//            return "The date is not available for WeatherKit"
//        case .weatherKitNoData:
//            return "WeatherKit returned an empty array"
//        }
//    }
//}
