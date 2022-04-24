//
//  PlaceListPresenter.swift
//  Weather
//
//  Created by Анатолий Миронов on 13.04.2022.
//

import Foundation

// MARK: - PlaceListPresenterProtocol (Connection View -> Presenter)
protocol PlaceListPresenterProtocol {
    var weatherForecastCurrentDestination: WeatherForecast? { get }
    var weatherForecasts: [WeatherForecast] { get }
    var numberOfSections: Int { get }
    var heightForRow: Int { get }
    init(view: PlaceListTableViewProtocol)
    
    func getNumberOfRowsInSection(_ section: Int) -> Int
    func deleteButtonTapped(indexPath: IndexPath)
    func getWeatherForecast()
    func getWeatherForecastCurrentLocation()
    func setListOfWeatherForecasts(_ forecastList: [WeatherForecast])
    func cellPresenter(at indexPath: IndexPath, isZeroSection: Bool) -> PlaceCellPresenterProtocol?
    func searchButtonClicked(text: String)
    func getCurrentPlace()
}

class PlaceListPresenter: PlaceListPresenterProtocol, LocationManagerPlaceListDelegate {

    var weatherForecastCurrentDestination: WeatherForecast?
    var weatherForecasts: [WeatherForecast] = []
    var numberOfSections = 2
    var heightForRow = 70
    
    private unowned let view: PlaceListTableViewProtocol
    
    required init(view: PlaceListTableViewProtocol) {
        self.view = view
    }
    
    func getNumberOfRowsInSection(_ section: Int) -> Int {
        section == 0 ? 1 : weatherForecasts.count
    }
    
    func deleteButtonTapped(indexPath: IndexPath) {
        weatherForecasts.remove(at: indexPath.row)
        view.deleteRow(indexPath: indexPath)
    }
    
    func getWeatherForecast() {
        NetworkManager.shared.fetchWeatherForecastByCityName(url: NetworkManager.shared.cityUrl) { result in
            switch result {
            case .success(let weatherForecast):
                self.weatherForecasts.append(weatherForecast)
                self.view.insertRow()
            case .failure(let error):
                DispatchQueue.main.async {
                    self.view.showError(message: "The place was not founded")
                }
                print(error)
            }
        }
    }
    
    func setListOfWeatherForecasts(_ forecastList: [WeatherForecast]) {
        weatherForecasts = forecastList
    }
    
    func searchButtonClicked(text: String) {
        NetworkManager.shared.city = text
        getWeatherForecast()
    }
    
    func cellPresenter(at indexPath: IndexPath, isZeroSection: Bool) -> PlaceCellPresenterProtocol? {
        switch isZeroSection {
        case true:
            if let weatherForecast = weatherForecastCurrentDestination {
                return PlaceCellPresenter(forecast: weatherForecast)
            }
        case false:
            let weatherForecast = weatherForecasts[indexPath.row]
            return PlaceCellPresenter(forecast: weatherForecast)
        }
        return nil
    }
    
    // Location
    func getCurrentPlace() {
        LocationManager.shared.setLocationManager()
        LocationManager.shared.delegatePlaceList = self
    }
    
    func didUpdateLocation() {
        getWeatherForecastCurrentLocation()
    }
    
    // Network
    func getWeatherForecastCurrentLocation() {
        NetworkManager.shared.fetchWeatherForecastByLocation(url: NetworkManager.shared.locationUrl) { result in
            switch result {
            case .success(let weatherForecast):
                self.weatherForecastCurrentDestination = weatherForecast
                let rowIndex = IndexPath(row: 0, section: 0)
                self.view.reloadRows(indexPath: rowIndex)
            case .failure(let error):
                print(error)
            }
        }
    }
}
