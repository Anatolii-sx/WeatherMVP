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
    init(forecast: ForecastCore)
    func getTitle(completion: @escaping(String) -> Void)
}

class PlaceCellPresenter: PlaceCellPresenterProtocol {

    private var forecast: ForecastCore
    
    var temperature: String {
        "\(forecast.current?.temp.getRound ?? 0 )º"
    }
    
    var time: String {
        Formatter.getFormat(
            unixTime: Int(forecast.current?.dt ?? 0),
            timezone: forecast.timezone ?? "",
            formatType: Formatter.FormatType.hoursAndMinutes.rawValue
        )
    }
    
    required init(forecast: ForecastCore) {
        self.forecast = forecast
    }
    
    func getTitle(completion: @escaping(String) -> Void) {
        guard let title = forecast.title else { return }
        
        if title.isEmpty {
            GeoCoder.shared.getPlace(latitude: forecast.lat, longitude: forecast.lon) { place in
                self.forecast.title = place
                StorageManager.shared.saveContext()
                completion(place)
            }
        } else {
            completion(title)
        }
    }
}
