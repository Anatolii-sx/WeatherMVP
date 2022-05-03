//
//  TimeTemperatureCellPresenter.swift
//  Weather
//
//  Created by Анатолий Миронов on 17.04.2022.
//

import Foundation

protocol TimeTemperatureCellProtocol {
    var time: String { get }
    var temperature: String { get }
    init(forecast: HourlyCore, timezone: String)
    func getImage(completion: @escaping(Data) -> Void)
}

class TimeTemperatureCellPresenter: TimeTemperatureCellProtocol {
    
    private var forecast: HourlyCore
    private var timezone: String
    
    var time: String {
        Formatter.getFormat(
            unixTime: Int(forecast.dt),
            timezone: timezone,
            formatType: Formatter.FormatType.hours.rawValue
        )
    }
    
    var temperature: String {
        return "\(forecast.temp.getRound)º"
    }
    
    required init(forecast: HourlyCore, timezone: String) {
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
