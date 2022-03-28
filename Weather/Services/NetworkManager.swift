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
    
    private let key = "01ada1995824bb19b1fc62b722cc7231"
    private let latitude = "33.44"
    private let longitude = "-94.04"
    
    var url: String {
        "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longitude)&appid=\(key)"
    }
    
    private init() {}
    
    func fetchWeather(url: String, completion: @escaping(Result<WeatherForecast, NetworkError>) -> Void) {
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
}
