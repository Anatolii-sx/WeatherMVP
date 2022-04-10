//
//  WeatherForecast.swift
//  Weather
//
//  Created by Анатолий Миронов on 27.03.2022.
//

struct WeatherForecast: Decodable {
    let lat: Double?
    let lon: Double?
    let timezone: String?
    let timezoneOffset: Int?
    let current: Current?
    let hourly: [Hourly]?
    let daily: [Daily]?
}

// MARK: - Current
struct Current: Decodable {
    let dt: Int?
    let sunrise: Int?
    let sunset: Int?
    let temp: Double?
    let feelsLike: Double?
    let pressure: Int?
    let humidity: Int?
    let uvi: Double?
    let clouds: Int?
    let visibility: Int?
    let windSpeed: Double?
    let weather: [Weather]?
}

// MARK: - Hourly
struct Hourly: Decodable {
    let dt: Int?
    let temp: Double?
    let weather: [Weather]?
}

// MARK: - Daily
struct Daily: Decodable {
    let dt: Int?
    let temp: Temp?
    let weather: [Weather]?
}

// MARK: - Weather
struct Weather: Decodable {
    let main: String?
    let description: String?
    let icon: String?
}

// MARK: - Temp
struct Temp: Decodable {
    let min: Double?
    let max: Double?
}
