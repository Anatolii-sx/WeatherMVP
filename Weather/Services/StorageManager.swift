//
//  StorageManager.swift
//  Weather
//
//  Created by Анатолий Миронов on 01.05.2022.
//

import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private let viewContext: NSManagedObjectContext
    
    private init() {
        viewContext = persistentContainer.viewContext
    }
    
    func fetchData(completion: (Result<[ForecastCore], Error>) -> Void) {
        let fetchRequest = ForecastCore.fetchRequest()

        do {
            let forecast = try viewContext.fetch(fetchRequest)
            completion(.success(forecast))
        } catch let error {
            completion(.failure(error))
        }
    }

    func delete(_ forecast: ForecastCore) {
        viewContext.delete(forecast)
        saveContext()
    }
    
    func deleteCurrentLocationPlace() {
        fetchData { result in
            switch result {
            case .success(let result):
                result.forEach { place in
                    if place.isCurrentLocation == true {
                        viewContext.delete(place)
                    }
                }
                saveContext()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func save(_ weatherForecast: WeatherForecast, isCurrentLocation: Bool, completion: ((ForecastCore) -> Void)?) {
        guard let entityDescriptionForecast = NSEntityDescription.entity(forEntityName: "ForecastCore", in: viewContext) else { return }
        guard let entityDescriptionCurrent = NSEntityDescription.entity(forEntityName: "CurrentCore", in: viewContext) else { return }
        
        guard let forecastCore = NSManagedObject(entity: entityDescriptionForecast, insertInto: viewContext) as? ForecastCore else { return }
        guard let currentCore = NSManagedObject(entity: entityDescriptionCurrent, insertInto: viewContext) as? CurrentCore else { return }
        
        if let completion = completion {
            completion(setForecast(forecastCore, currentCore, weatherForecast, isCurrentLocation))
        }
        saveContext()
    }
    
    // Setting forecast depends on data from NetworkManager (connection CoreDataModel and WeatherForecast)
    private func setForecast(_ forecastCore: ForecastCore, _ currentCore: CurrentCore, _ weatherForecast: WeatherForecast, _ isCurrentLocation: Bool) -> ForecastCore {
        
        // ForecastCore
        forecastCore.title = ""
        forecastCore.isCurrentLocation = isCurrentLocation
        forecastCore.lat = weatherForecast.lat ?? 0
        forecastCore.lon = weatherForecast.lon ?? 0
        forecastCore.timezone = weatherForecast.timezone ?? ""
        forecastCore.timezoneOffset = Int64(weatherForecast.timezoneOffset ?? 0)
        
        // CurrentCore
        currentCore.dt = Int64(weatherForecast.current?.dt ?? 0)
        currentCore.sunrise = Int64(weatherForecast.current?.sunrise ?? 0)
        currentCore.sunset = Int64(weatherForecast.current?.sunset ?? 0)
        currentCore.temp = weatherForecast.current?.temp ?? 0
        currentCore.feelsLike = weatherForecast.current?.feelsLike ?? 0
        currentCore.pressure = Int64(weatherForecast.current?.pressure ?? 0)
        currentCore.humidity = Int64(weatherForecast.current?.humidity ?? 0)
        currentCore.uvi = weatherForecast.current?.uvi ?? 0
        currentCore.clouds = Int64(weatherForecast.current?.clouds ?? 0)
        currentCore.visibility = Int64(weatherForecast.current?.visibility ?? 0)
        currentCore.windSpeed = weatherForecast.current?.windSpeed ?? 0
        
        weatherForecast.current?.weather?.forEach({ weather in
            
            guard let entityDescriptionWeather = NSEntityDescription.entity(forEntityName: "WeatherCore", in: viewContext) else { return }
            guard let weatherCore = NSManagedObject(entity: entityDescriptionWeather, insertInto: viewContext) as? WeatherCore else { return }
            
            weatherCore.main = weather.main ?? ""
            weatherCore.describe = weather.description ?? ""
            weatherCore.icon = weather.icon ?? ""
            
            // connection WeatherCore -> CurrentCore
            weatherCore.currentInversion = currentCore
        })
        
        // connection CurrentCore -> ForecastCore
        currentCore.forecastInversion = forecastCore
        
        // HourlyCore
        weatherForecast.hourly?.forEach({ hourly in
            
            guard let entityDescriptionHourly = NSEntityDescription.entity(forEntityName: "HourlyCore", in: viewContext) else { return }
            guard let entityDescriptionWeather = NSEntityDescription.entity(forEntityName: "WeatherCore", in: viewContext) else { return }
            
            guard let hourlyCore = NSManagedObject(entity: entityDescriptionHourly, insertInto: viewContext) as? HourlyCore else { return }
            guard let weatherCore = NSManagedObject(entity: entityDescriptionWeather, insertInto: viewContext) as? WeatherCore else { return }
            
            hourlyCore.dt = Int64(hourly.dt ?? 0)
            hourlyCore.temp = hourly.temp ?? 0
            
            hourly.weather?.forEach({ weather in
                weatherCore.main = weather.main ?? ""
                weatherCore.describe = weather.description ?? ""
                weatherCore.icon = weather.icon ?? ""
                
                // connection HourlyCore -> WeatherCore
                hourlyCore.addToWeather(weatherCore)
            })

            // connection ForecastCore -> HourlyCore
            forecastCore.addToHourly(hourlyCore)
        })
        
        // DailyCore
        weatherForecast.daily?.forEach({ daily in
            
            guard let entityDescriptionDaily = NSEntityDescription.entity(forEntityName: "DailyCore", in: viewContext) else { return }
            guard let entityDescriptionTemp = NSEntityDescription.entity(forEntityName: "TempCore", in: viewContext) else { return }
            
            guard let dailyCore = NSManagedObject(entity: entityDescriptionDaily, insertInto: viewContext) as? DailyCore else { return }
            guard let tempCore = NSManagedObject(entity: entityDescriptionTemp, insertInto: viewContext) as? TempCore else { return }
            
            dailyCore.dt = Int64(daily.dt ?? 0)
            tempCore.max = daily.temp?.max ?? 0
            tempCore.min = daily.temp?.min ?? 0
            
            // connection tempCore -> dailyCore
            tempCore.dailyInversion = dailyCore
            
            daily.weather?.forEach({ weather in
                
                guard let entityDescriptionWeather = NSEntityDescription.entity(forEntityName: "WeatherCore", in: viewContext) else { return }
                guard let weatherCore = NSManagedObject(entity: entityDescriptionWeather, insertInto: viewContext) as? WeatherCore else { return }
                
                weatherCore.main = weather.main ?? ""
                weatherCore.describe = weather.description ?? ""
                weatherCore.icon = weather.icon ?? ""
                
                // connection DailyCore -> WeatherCore
                dailyCore.addToWeather(weatherCore)
            })
            
            // connection ForecastCore -> DailyCore
            forecastCore.addToDaily(dailyCore)
        })
        
        return forecastCore
    }
    
    // MARK: - Core Data Saving support
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
