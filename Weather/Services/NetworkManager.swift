//
//  NetworkManager.swift
//  Weather
//
//  Created by Анатолий Миронов on 27.03.2022.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

class NetworkManager {
    static let shared = NetworkManager()
    
    var latitude = ""
    var longitude = ""
    var city = ""
    
    private let key = "01ada1995824bb19b1fc62b722cc7231"
    private let metric = "metric"
    private var icon = ""
    
    var locationUrl: String {
        "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longitude)&appid=\(key)&units=\(metric)"
    }
    
    var cityUrl: String {
        "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(key)"
    }
    
    var imageURL: String {
        "https://openweathermap.org/img/wn/\(icon)@2x.png"
    }
    
    private init() {}
    
    func fetchWeatherForecastByLocation(url: String, completion: @escaping(Result<WeatherForecast, NetworkError>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let weather = try decoder.decode(WeatherForecast.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(weather))
                }
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func fetchWeatherForecastByCityName(url: String, completion: @escaping(Result<WeatherForecast, NetworkError>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let city = try JSONDecoder().decode(City.self, from: data)
                
                guard let cityName = city.name else { return }
                self.city = cityName
                self.latitude = "\(city.coord.lat ?? 0)"
                self.longitude = "\(city.coord.lon ?? 0)"
                
                self.fetchWeatherForecastByLocation(url: self.locationUrl) { result in
                    switch result {
                    case .success(let weatherForecast):
                        DispatchQueue.main.async {
                            completion(.success(weatherForecast))
                        }
                    case .failure(_):
                        completion(.failure(.decodingError))
                    }
                }
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func fetchWeatherImage(icon: String, completion: @escaping(Data?) -> Void) {
        self.icon = icon
        
        guard let url = URL(string: imageURL) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }

            DispatchQueue.main.async {
                completion(data)
            }
        }.resume()
    }
}
