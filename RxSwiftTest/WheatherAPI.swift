//
//  ApiController.swift
//  RxSwiftTest
//
//  Created by Ran Helfer on 27/12/2021.
//

import Foundation
import RxSwift

enum DecodableError: Error {
    case decodingError
}

struct ErrorWhileDecoding: Decodable {
    let error: Error
    
    enum CodingKeys: String, CodingKey {
            case error = "error"
    }
    
    init(error: Error) {
        self.error = error
    }
    
    init(from decoder: Decoder) throws {
        self.error = DecodableError.decodingError
    }
}

extension Decodable {
    static func observableRequestForModel(request: URLRequest) -> Observable<Decodable> {
        return URLSession.shared.rx.data(request: request).map({ data in
            do {
                let model = try JSONDecoder().decode(Self.self, from: data)
                return model
            } catch let error {
                return ErrorWhileDecoding(error: error)
            }
        })
    }
}

class ApiController {
    
    static let shared = ApiController.init()
    let apiKey = "ce9c6247ec5b529de72e47123fb3a403"
    let baseUrlSting = "http://api.openweathermap.org/data/2.5/weather"
    
    func currentWeather(city: String) -> Observable<Weather> {
        var components = URLComponents(string:baseUrlSting)
        let query_city = URLQueryItem(name: "q", value: city)
        let query_appId = URLQueryItem(name: "appid", value: apiKey)
        components?.queryItems = [query_city, query_appId]
        
        var request = URLRequest(url: components!.url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return Weather.observableRequestForModel(request: request).map({ model in
            if let _ = model as? ErrorWhileDecoding {
                return Weather.someWeather()
            }
            return model as! Weather
        })
    }
    
    
    func imageForIconId(iconUrlString: String) -> Observable<UIImage> {
        var request = URLRequest(url: URL(string:iconUrlString)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return URLSession.shared.rx.data(request: request).map({ data in
            return UIImage(data: data)!
        })
    }
    
}
