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
    var weatherForecast: ForecastCore? { get }
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
        guard let weather = weatherForecast?.current?.weather?.allObjects as? [WeatherCore] else { return "" }
        return weather.first?.main ?? ""
    }
    
    var weatherDescriptions: [[String: Any]] {
        [
            ["sunrise": Formatter.getFormat(
                unixTime: Int(weatherForecast?.current?.sunrise ?? 0),
                timezone: weatherForecast?.timezone ?? "",
                formatType: Formatter.FormatType.hoursAndMinutes.rawValue
            )],
            ["sunset": Formatter.getFormat(
                unixTime: Int(weatherForecast?.current?.sunset ?? 0),
                timezone: weatherForecast?.timezone ?? "",
                formatType: Formatter.FormatType.hoursAndMinutes.rawValue
            )],
            ["humidity": "\(weatherForecast?.current?.humidity ?? 0) %"],
            ["wind": "\(weatherForecast?.current?.windSpeed.getRound ?? 0) m/s"],
            ["feels like": "\(weatherForecast?.current?.feelsLike.getRound ?? 0)º"],
            ["pressure": "\(Double(weatherForecast?.current?.pressure ?? 0) * 0.75) mm Hg"],
            ["visibility": "\(Double(weatherForecast?.current?.visibility ?? 0)/1000) km"],
            ["uv index": weatherForecast?.current?.uvi.getRound ?? 0]
        ]
    }
    
    var weatherForecast: ForecastCore?
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
        guard let hourlyForecasts = weatherForecast?.hourly?.allObjects as? [HourlyCore] else { return nil }
        let hourlySorted = hourlyForecasts.sorted { $0.dt < $1.dt }
        return TimeTemperatureCellPresenter(forecast: hourlySorted[indexPath.row], timezone: weatherForecast?.timezone ?? "")
    }
    
    func cellDayTemperaturePresenter(at indexPath: IndexPath) -> DayTemperatureCellProtocol? {
        guard let dailyForecasts = weatherForecast?.daily?.allObjects as? [DailyCore] else { return nil }
        let dailySorted = dailyForecasts.sorted { $0.dt < $1.dt }
        return DayTemperatureCellPresenter(forecast: dailySorted[indexPath.row], timezone: weatherForecast?.timezone ?? "")
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
        guard let title = weatherForecast?.title else { return }
        
        if title.isEmpty {
            GeoCoder.shared.getPlace(latitude: weatherForecast?.lat ?? 0, longitude: weatherForecast?.lon ?? 0) { place in
                self.weatherForecast?.title = place
                StorageManager.shared.saveContext()
                completion(place)
            }
        } else {
            completion(title)
        }
    }
    
    // Network
    func getWeatherForecast() {
        NetworkManager.shared.fetchWeatherForecastByLocation(url: NetworkManager.shared.locationUrl) { result in
            switch result {
            case .success(let weatherForecast):
                StorageManager.shared.deleteCurrentLocationPlace()
                StorageManager.shared.save(weatherForecast, isCurrentLocation: true) { forecast in
                    self.weatherForecast = forecast
                }
                
                self.getPlace { place in
                    DispatchQueue.main.async {
                        self.view.getPlaceName(place)
                    }
                }
                
                DispatchQueue.main.async {
                    self.view.updateViews()
                }
            case .failure(let error):
                print(error)
                self.getCurrentLocationForecastFromCoreData()
            
                DispatchQueue.main.async {
                    self.view.showError(message: "Check your internet connection")
                }
            }
        }
    }
    
    func getCurrentLocationForecastFromCoreData() {
        StorageManager.shared.fetchData { result in
            switch result {
            case .success(let result):
                let currentLocationForecast = result.filter { $0.isCurrentLocation == true }
                self.weatherForecast = currentLocationForecast.first
                
                self.getPlace { place in
                    DispatchQueue.main.async {
                        self.view.getPlaceName(place)
                    }
                }
                
                DispatchQueue.main.async {
                    self.view.updateViews()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
