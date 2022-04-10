//
//  CityListTableViewController.swift
//  Weather
//
//  Created by Анатолий Миронов on 03.04.2022.
//

import UIKit
import CoreLocation

class CityListTableViewController: UITableViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    
    private func setLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let first = locations.first else { return }
        NetworkManager.shared.latitude =  String(format: "%.4f", first.coordinate.latitude)
        NetworkManager.shared.longitude = String(format: "%.4f", first.coordinate.longitude)
        locationManager.stopUpdatingLocation()
        getWeatherForecastCurrentLocation()
    }
    
    private let searchVC = UISearchController(searchResultsController: nil)
    var weatherForecasts: [WeatherForecast] = []
    var weatherForecastCurrentDestination: WeatherForecast?
    var delegate: CityListTableViewControllerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        setLocationManager()
        createSearchBar()
        tableView.register(CityTableViewCell.self, forCellReuseIdentifier: CityTableViewCell.cellID)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let city = searchBar.text {
            NetworkManager.shared.city = city
            getWeatherForecast()
        }
    }
    
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : weatherForecasts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        switch indexPath.section {
        case 0:
            guard let cityCell = tableView.dequeueReusableCell(withIdentifier: "CityID", for: indexPath) as? CityTableViewCell else { return  UITableViewCell() }
            if let forecast = weatherForecastCurrentDestination {
                cityCell.configure(forecast: forecast, isLocationImageHidden: false)
            }
            cell = cityCell
        case 1:
            guard let cityCell = tableView.dequeueReusableCell(withIdentifier: "CityID", for: indexPath) as? CityTableViewCell else { return  UITableViewCell() }
            let weatherForecast = weatherForecasts[indexPath.row]
            cityCell.configure(forecast: weatherForecast, isLocationImageHidden: true)
            cell = cityCell
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath.section {
        case 0:
            if let forecast = weatherForecastCurrentDestination {
                delegate.setWeatherForecast(forecast)
            }
        case 1:
            let forecast = weatherForecasts[indexPath.row]
            delegate.setWeatherForecast(forecast)
        default:
            break
        }
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            if editingStyle == .delete {
                weatherForecasts.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        default :
            break
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(
            title: "🙁",
            message: "The place was not founded",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default,
                handler: { _ in self.searchVC.isActive = false }
            )
        )
        
        present(alert, animated: true)
    }
    
    // MARK: - Search Bar
    private func createSearchBar() {
        navigationItem.searchController = searchVC
        searchVC.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

extension CityListTableViewController {
    private func getWeatherForecast() {
        NetworkManager.shared.fetchWeatherForecastByCityName(url: NetworkManager.shared.cityUrl) { result in
            switch result {
            case .success(let weatherForecast):
                self.weatherForecasts.append(weatherForecast)
                self.tableView.insertRows(at: [IndexPath(row: self.weatherForecasts.count - 1, section: 1)], with: .automatic)
                self.searchVC.isActive = false
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlert()
                }
                print(error)
            }
        }
    }
    
    private func getWeatherForecastCurrentLocation() {
        NetworkManager.shared.fetchWeatherForecastByLocation(url: NetworkManager.shared.locationUrl) { result in
            switch result {
            case .success(let weatherForecast):
                self.weatherForecastCurrentDestination = weatherForecast
                let rowIndex = IndexPath(row: 0, section: 0)
                self.tableView.reloadRows(at: [rowIndex], with: .automatic)
            case .failure(let error):
                print(error)
            }
        }
    }
}