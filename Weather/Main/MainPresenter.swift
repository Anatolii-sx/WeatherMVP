//
//  MainPresenter.swift
//  Weather
//
//  Created by Анатолий Миронов on 17.04.2022.
//

import Foundation

// MARK: - MainPresenterProtocol (Connection View -> Presenter)
protocol MainPresenterProtocol {
    var forecastList: [WeatherForecast] { get }
    var weatherForecast: WeatherForecast? { get }
    var weatherDescriptions: [[String: Any]] { get }
    var weatherStatus: String { get }
    var temperature: String { get }
    var numberOfItemsInSectionCollectionView: Int { get }
    var numberOfRowsDailyTableViewSection: Int { get }
    var numberOfRowsDescriptionTableViewSection: Int { get }
    init(view: MainViewControllerProtocol)
    
    func cellTimeTemperaturePresenter(at indexPath: IndexPath) -> TimeTemperatureCellProtocol?
    func cellDayTemperaturePresenter(at indexPath: IndexPath) -> DayTemperatureCellProtocol?
    func cellDescriptionPresenter(at indexPath: IndexPath) -> DescriptionCellProtocol?
    func getWeatherForecast()
    func getCurrentPlace()
    func getPlace(completion: @escaping(String) -> Void)
}

class MainPresenter: MainPresenterProtocol, LocationManagerMainDelegate {
    
    var numberOfItemsInSectionCollectionView: Int {
        weatherForecast?.hourly?.count ?? 0
    }
    
    var numberOfRowsDailyTableViewSection: Int {
        weatherForecast?.daily?.count ?? 0
    }
    
    var numberOfRowsDescriptionTableViewSection: Int {
        weatherDescriptions.count
    }
    
    var temperature: String {
        guard let temperature = weatherForecast?.current?.temp else { return "" }
        return "\(temperature.getRound)ºC"
    }
    
    var weatherStatus: String {
        weatherForecast?.current?.weather?.first?.main ?? ""
    }
    
    var weatherDescriptions: [[String: Any]] {
        [
            ["sunrise": Formatter.getFormat(
                unixTime: weatherForecast?.current?.sunrise ?? 0,
                timezone: weatherForecast?.timezone ?? "",
                formatType: Formatter.FormatType.hoursAndMinutes.rawValue
            )],
            ["sunset": Formatter.getFormat(
                unixTime: weatherForecast?.current?.sunset ?? 0,
                timezone: weatherForecast?.timezone ?? "",
                formatType: Formatter.FormatType.hoursAndMinutes.rawValue
            )],
            ["humidity": "\(weatherForecast?.current?.humidity ?? 0) %"],
            ["wind": "\(weatherForecast?.current?.windSpeed?.getRound ?? 0) m/s"],
            ["feels like": "\(weatherForecast?.current?.feelsLike?.getRound ?? 0)º"],
            ["pressure": "\(Double(weatherForecast?.current?.pressure ?? 0) * 0.75) mm Hg"],
            ["visibility": "\(Double(weatherForecast?.current?.visibility ?? 0)/1000) km"],
            ["uv index": weatherForecast?.current?.uvi?.getRound ?? 0]
        ]
    }
    
    var weatherForecast: WeatherForecast?
    var forecastList: [WeatherForecast] = []
    
    private unowned let view: MainViewControllerProtocol
    
    required init(view: MainViewControllerProtocol) {
        self.view = view
    }
    
    func cellDescriptionPresenter(at indexPath: IndexPath) -> DescriptionCellProtocol? {
        let description = weatherDescriptions[indexPath.row]
        return DescriptionCellPresenter(description: description)
    }
    
    func cellTimeTemperaturePresenter(at indexPath: IndexPath) -> TimeTemperatureCellProtocol? {
        guard let hourlyForecasts = weatherForecast?.hourly else { return nil }
        return TimeTemperatureCellPresenter(forecast: hourlyForecasts[indexPath.row], timezone: weatherForecast?.timezone ?? "")
    }
    
    func cellDayTemperaturePresenter(at indexPath: IndexPath) -> DayTemperatureCellProtocol? {
        guard let dailyForecasts = weatherForecast?.daily else { return nil }
        return DayTemperatureCellPresenter(forecast: dailyForecasts[indexPath.row], timezone: weatherForecast?.timezone ?? "")
    }
    
    // Location
    func getCurrentPlace() {
        LocationManager.shared.setLocationManager()
        LocationManager.shared.delegateMain = self
    }
    
    func didUpdateLocation() {
        getWeatherForecast()
    }
    
    func getPlace(completion: @escaping (String) -> Void) {
        GeoCoder.shared.getPlace(latitude: weatherForecast?.lat ?? 0, longitude: weatherForecast?.lon ?? 0) { place in
            completion(place)
        }
    }
    
    // Network
    func getWeatherForecast() {
        NetworkManager.shared.fetchWeatherForecastByLocation(url: NetworkManager.shared.locationUrl) { result in
            switch result {
            case .success(let weatherForecast):
                self.weatherForecast = weatherForecast
                self.getPlace { place in
                    self.view.getPlaceName(place)
                }
                self.view.updateViews()
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self.view.showError(message: "Check your internet connection")
                }
            }
        }
    }
}
