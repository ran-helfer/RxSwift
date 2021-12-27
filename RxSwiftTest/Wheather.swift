//
//  Wheather.swift
//  RxSwiftTest
//
//  Created by Ran Helfer on 27/12/2021.
//

import Foundation

struct WeatherMain: Decodable {
    let temp: Double
    let humidity: Int
}

struct WeatherDescription: Decodable {
    let main: String
    let description: String
    let icon: String
    
    var iconUrl: String {
        return "http://openweathermap.org/img/wn/" + icon + "@2x.png"
    }
}

struct Weather: Decodable {
    let name: String
    let weather: [WeatherDescription]
    let main: WeatherMain
    
    static func someWeather() -> Weather {
        return Weather(name: "test", weather: [WeatherDescription(main: "clear", description: "clear", icon: "01d")], main: WeatherMain(temp: -5, humidity: -5))
    }
}
