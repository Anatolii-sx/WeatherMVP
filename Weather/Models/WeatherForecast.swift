//
//  WeatherForecast.swift
//  Weather
//
//  Created by Анатолий Миронов on 27.03.2022.
//

struct WeatherForecast: Decodable {
    let lat, lon: Double?
    let timezone: String?
    let timezoneOffset: Int?
    let current: Current?
    let hourly: [Hourly]?
    let daily: [Daily]?
}

// MARK: - Current
struct Current: Decodable {
    let dt: Int?
    let sunrise, sunset: Int?
    let temp, feelsLike: Double?
    let pressure, humidity: Int?
    let dewPoint, uvi: Double?
    let clouds, visibility: Int?
    let windSpeed: Double?
    let windDeg: Int?
    let weather: [Weather]?
}

// MARK: - Hourly
struct Hourly: Decodable {
    let dt: Int?
    let temp, feelsLike: Double?
    let pressure, humidity: Int?
    let dewPoint, uvi: Double?
    let clouds, visibility: Int?
    let windSpeed: Double?
    let windDeg: Int?
    let windGust: Double?
    let weather: [Weather]?
    let pop: Double?
}

// MARK: - Daily
struct Daily: Decodable {
    let dt, sunrise, sunset, moonrise: Int?
    let moonset: Int?
    let moonPhase: Double?
    let temp: Temp?
    let feelsLike: FeelsLike?
    let pressure, humidity: Int?
    let dewPoint, windSpeed: Double?
    let windDeg: Int?
    let windGust: Double?
    let weather: [Weather]?
    let clouds: Int?
    let pop, uvi: Double?
}

// MARK: - Weather
struct Weather: Decodable {
    let id: Int?
    let main: String?
    let description: String?
    let icon: String?
}

// MARK: - FeelsLike
struct FeelsLike: Decodable {
    let day, night, eve, morn: Double?
}

// MARK: - Temp
struct Temp: Decodable {
    let day, min, max, night, eve, morn: Double?
}
