//
//  PlaceCellPresenter.swift
//  Weather
//
//  Created by Анатолий Миронов on 16.04.2022.
//

import Foundation

protocol PlaceCellPresenterProtocol {
    var temperature: String { get }
    var time: String { get }
    init(forecast: WeatherForecast)
    func getTitle(completion: @escaping(String) -> Void)
}

class PlaceCellPresenter: PlaceCellPresenterProtocol {

    private var forecast: WeatherForecast
    
    var temperature: String {
        "\(forecast.current?.temp?.getRound ?? 0 )º"
    }
    
    var time: String {
        Formatter.getFormat(
            unixTime: forecast.current?.dt ?? 0,
            timezone: forecast.timezone ?? "",
            formatType: Formatter.FormatType.hoursAndMinutes.rawValue
        )
    }
    
    required init(forecast: WeatherForecast) {
        self.forecast = forecast
    }
    
    func getTitle(completion: @escaping(String) -> Void) {
        GeoCoder.shared.getPlace(latitude: forecast.lat ?? 0, longitude: forecast.lon ?? 0) { place in
            completion(place)
        }
    }
}
