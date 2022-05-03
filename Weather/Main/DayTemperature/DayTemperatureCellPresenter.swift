//
//  DayTemperatureCellPresenter.swift
//  Weather
//
//  Created by Анатолий Миронов on 18.04.2022.
//

import Foundation

protocol DayTemperatureCellProtocol {
    var day: String { get }
    var maxTemp: String { get }
    var minTemp: String { get }
    init(forecast: DailyCore, timezone: String)
    func getImage(completion: @escaping(Data) -> Void)
}

class DayTemperatureCellPresenter: DayTemperatureCellProtocol {
    
    private var forecast: DailyCore
    private var timezone: String
    
    var day: String {
        Formatter.getFormat(
            unixTime: Int(forecast.dt),
            timezone: timezone,
            formatType: Formatter.FormatType.days.rawValue
        )
    }
    
    var maxTemp: String {
        guard let maxTemp = forecast.temp?.max else { return "" }
        return "\(maxTemp.getRound)"
    }
    
    var minTemp: String {
        guard let minTemp = forecast.temp?.min else { return "" }
        return "\(minTemp.getRound)"
    }
    
    required init(forecast: DailyCore, timezone: String) {
        self.forecast = forecast
        self.timezone = timezone
    }
    
    func getImage(completion: @escaping (Data) -> Void) {
        guard let weather = forecast.weather?.allObjects as? [WeatherCore] else { return }
        
        NetworkManager.shared.fetchWeatherImage(icon: weather.first?.icon ?? "") { imageData in
            if let imageData = imageData {
                completion(imageData)
            }
        }
    }
}
