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
    init(forecast: Hourly, timezone: String)
    func getImage(completion: @escaping(Data) -> Void)
}

class TimeTemperatureCellPresenter: TimeTemperatureCellProtocol {
    
    private var forecast: Hourly
    private var timezone: String
    
    var time: String {
        Formatter.getFormat(
            unixTime: forecast.dt ?? 0,
            timezone: timezone,
            formatType: Formatter.FormatType.hours.rawValue
        )
    }
    
    var temperature: String {
        guard let temperature = forecast.temp else { return "" }
        return "\(temperature.getRound)º"
    }
    
    required init(forecast: Hourly, timezone: String) {
        self.forecast = forecast
        self.timezone = timezone
    }
    
    func getImage(completion: @escaping (Data) -> Void) {
        NetworkManager.shared.fetchWeatherImage(icon: forecast.weather?.first?.icon ?? "") { imageData in
            if let imageData = imageData {
                completion(imageData)
            }
        }
    }
}
