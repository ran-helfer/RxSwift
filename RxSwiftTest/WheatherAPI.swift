//
//  ApiController.swift
//  RxSwiftTest
//
//  Created by Ran Helfer on 27/12/2021.
//

import Foundation
import RxSwift

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
        
        return URLSession.shared.rx.data(request: request).map({ data in
            do {
                let weather = try JSONDecoder().decode(Weather.self, from: data)
                return weather
            } catch let error {
                print(error)
            }
            return Weather.someWeather()
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
