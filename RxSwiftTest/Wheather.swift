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
        return Weather(name: "-", weather: [WeatherDescription(main: "-", description: "-", icon: "")], main: WeatherMain(temp: 0, humidity: 0))
    }
}
