//
//  MainViewController.swift
//  Weather
//
//  Created by Анатолий Миронов on 23.03.2022.
//

import UIKit
import CoreLocation

protocol CityListTableViewControllerDelegate {
    func setWeatherForecast(_ forecast: WeatherForecast)
    func rememberCityList(_ weatherForecasts: [WeatherForecast])
}

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    private var cityList: [WeatherForecast] = []
    
    private let primaryColor = UIColor(
        red: 1/255,
        green: 255/255,
        blue: 255/255,
        alpha: 0.4
    )
    
    private let secondaryColor = UIColor(
        red: 25/255,
        green: 33/255,
        blue: 78/255,
        alpha: 0.4
    )
    
    private var locationManager = CLLocationManager()
    private var weatherForecast: WeatherForecast?
    private var weatherDescriptions: [[String: Any]] {
        [
            ["sunrise": getFormat(seconds: weatherForecast?.current?.sunrise ?? 0)],
            ["sunset": getFormat(seconds: weatherForecast?.current?.sunset ?? 0)],
            ["humidity": "\(weatherForecast?.current?.humidity ?? 0) %"],
            ["wind": "\(weatherForecast?.current?.windSpeed?.getRound ?? 0) m/s"],
            ["feels like": "\(weatherForecast?.current?.feelsLike?.getRound ?? 0)º"],
            ["pressure": "\(Double(weatherForecast?.current?.pressure ?? 0) * 0.75) mm Hg"],
            ["visibility": "\(Double(weatherForecast?.current?.visibility ?? 0)/1000) km"],
            ["uv index": weatherForecast?.current?.uvi?.getRound ?? 0]
        ]
    }
    
    // НУЖНО СДЕЛАТЬ ОДНУ УНИВЕРСАЛЬНУЮ ФУНКЦИЮ format для всех. Два параметра, дженерик тип и enum (кейсы - выдаваемый формат HH, HH:mm, ...)
    private func getFormat(seconds: Int) -> String {
        
        let time = Double(seconds)
        let date = "\(Date(timeIntervalSince1970: time))"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        guard let theDate = dateFormatter.date(from: date) else { return "" }

        let newDateFormatter = DateFormatter()
        newDateFormatter.timeZone = TimeZone(identifier: weatherForecast?.timezone ?? "")
        newDateFormatter.dateFormat = "HH:mm"
        
        return newDateFormatter.string(from: theDate)
    }
    
    private func setToolbar() {
        navigationController?.isToolbarHidden = false
        
        let locationButton = UIBarButtonItem(
            image: UIImage(systemName: "location"),
            style: .done,
            target: self,
            action: #selector(locationButtonTapped)
        )
        
        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: self,
            action: .none
        )
        
        let listButton = UIBarButtonItem(
            image: UIImage(systemName: "list.bullet"),
            style: .done,
            target: self,
            action: #selector(listButtonTapped)
        )
        
        locationButton.tintColor = .white
        listButton.tintColor = .white
        
        navigationController?.toolbar.barTintColor = .black
        navigationController?.toolbar.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        toolbarItems = [locationButton, flexibleSpace, listButton]
    }
    
    @objc private func listButtonTapped() {
        let cityListVC = CityListTableViewController()
        cityListVC.delegate = self
        cityListVC.weatherForecasts = cityList
        let navController = UINavigationController(rootViewController: cityListVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
        toolbarItems?.first?.image = UIImage(systemName: "location")
    }
    
    @objc private func locationButtonTapped() {
        locationManager.startUpdatingLocation()
        toolbarItems?.first?.image = UIImage(systemName: "location.fill")
    }
    
    private lazy var mainScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    // MARK: - Header Views
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            cityLabel,
            weatherStatusLabel,
            temperatureLabel
        ])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        return stackView
    }()
    
    private lazy var cityLabel: UILabel = {
        let cityLabel = UILabel()
        cityLabel.textAlignment = .center
        cityLabel.font = .systemFont(ofSize: 32, weight: .medium)
        cityLabel.textColor = .white
        return cityLabel
    }()
    
    private lazy var weatherStatusLabel: UILabel = {
        let weatherStatusLabel = UILabel()
        weatherStatusLabel.textAlignment = .center
        weatherStatusLabel.font = .systemFont(ofSize: 18, weight: .regular)
        weatherStatusLabel.textColor = .white
        return weatherStatusLabel
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let temperatureLabel = UILabel()
        temperatureLabel.textAlignment = .center
        temperatureLabel.font = .systemFont(ofSize: 40, weight: .medium)
        temperatureLabel.textColor = .white
        return temperatureLabel
    }()
    
    // MARK: - Main Views
    private lazy var timeTemperatureCollectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 3
        layout.itemSize = CGSize(width: 55, height: 150)
        return layout
    }()
    
    private lazy var timeTemperatureCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: timeTemperatureCollectionViewFlowLayout)
        collectionView.register(TimeTemperatureCollectionViewCell.self, forCellWithReuseIdentifier: TimeTemperatureCollectionViewCell.cellID)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var daysTemperatureTableView: UITableView = {
        let  tableView = UITableView()
        tableView.register(DayTemperatureTableViewCell.self, forCellReuseIdentifier: DayTemperatureTableViewCell.cellID)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var moreDescriptionTableView: UITableView = {
        let  tableView = UITableView()
        tableView.register(MoreDescriptionTableViewCell.self, forCellReuseIdentifier: MoreDescriptionTableViewCell.cellID)
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = false
        tableView.rowHeight = 65
        return tableView
    }()
    
    // MARK: - Methods of ViewController's Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        daysTemperatureTableView.backgroundColor = .clear
        moreDescriptionTableView.backgroundColor = .clear
        
        
        moreDescriptionTableView.separatorColor = .white
        
        
        setLocationManager()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setToolbar()
        getWeatherForecast()
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        view.addSubview(mainScrollView)
        addSubviewsIntoMainScrollView(
            headerStackView,
            timeTemperatureCollectionView,
            daysTemperatureTableView,
            moreDescriptionTableView
        )
        
        setAllConstraints()
        
        timeTemperatureCollectionView.delegate = self
        timeTemperatureCollectionView.dataSource = self
        
        daysTemperatureTableView.delegate = self
        daysTemperatureTableView.dataSource = self
        
        moreDescriptionTableView.delegate = self
        moreDescriptionTableView.dataSource = self
    }
    
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
        getWeatherForecast()
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: first.coordinate.latitude, longitude: first.coordinate.longitude)

        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) -> Void in
            placemarks?.forEach { (placemark) in
                if let city = placemark.locality {
                    self.cityLabel.text = city
                }
            }
        })
        locationManager.stopUpdatingLocation()
    }
    
    private func addSubviewsIntoMainScrollView(_ views: UIView...) {
        views.forEach { mainScrollView.addSubview($0) }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        weatherForecast?.hourly?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeTemperatureCollectionViewCell.cellID, for: indexPath) as? TimeTemperatureCollectionViewCell else { return UICollectionViewCell() }
        if let hourlyForecasts = weatherForecast?.hourly {
            cell.configure(forecast: hourlyForecasts[indexPath.row], timezone: weatherForecast?.timezone ?? "")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        
        if tableView == daysTemperatureTableView {
           count = weatherForecast?.daily?.count ?? 0
        } else if tableView == moreDescriptionTableView {
            count = weatherDescriptions.count
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if tableView == daysTemperatureTableView {
            guard let dayTemperatureCell = daysTemperatureTableView.dequeueReusableCell(withIdentifier: DayTemperatureTableViewCell.cellID) as? DayTemperatureTableViewCell else { return UITableViewCell() }
            if let dailyForecasts = weatherForecast?.daily {
                dayTemperatureCell.configure(forecast: dailyForecasts[indexPath.row], timezone: weatherForecast?.timezone ?? "")
            }
            cell = dayTemperatureCell
        } else if tableView == moreDescriptionTableView {
            guard let moreDescriptionCell = moreDescriptionTableView.dequeueReusableCell(withIdentifier: MoreDescriptionTableViewCell.cellID) as? MoreDescriptionTableViewCell else { return UITableViewCell() }
            let description = weatherDescriptions[indexPath.row]
            moreDescriptionCell.configure(description: description)
            cell = moreDescriptionCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func updateHeaderLabels() {
        weatherStatusLabel.text = weatherForecast?.current?.weather?.first?.main ?? ""
        
        if let temperature = weatherForecast?.current?.temp {
            temperatureLabel.text = "\(temperature.getRound)ºC"
        }
    }
    
    private func setAllConstraints() {
        setConstraintsScrollView()
        setConstraintsHeaderStackView()
        setConstraintsTimeTemperatureCollectionView()
        setConstraintsDaysTemperatureTableView()
        setConstraintsMoreDescriptionTableView()
    }
    
    private func setConstraintsScrollView() {
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            mainScrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            mainScrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            mainScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
    }
    
    private func setConstraintsHeaderStackView() {
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerStackView.heightAnchor.constraint(equalToConstant: 125),
            headerStackView.topAnchor.constraint(equalTo: mainScrollView.topAnchor, constant: 0),
            headerStackView.leftAnchor.constraint(equalTo: mainScrollView.leftAnchor, constant: 0),
            headerStackView.rightAnchor.constraint(equalTo: mainScrollView.rightAnchor, constant: 0),
            headerStackView.bottomAnchor.constraint(equalTo: timeTemperatureCollectionView.topAnchor, constant: -10),
            headerStackView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor)
        ])
    }
    
    private func setConstraintsTimeTemperatureCollectionView() {
        timeTemperatureCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeTemperatureCollectionView.heightAnchor.constraint(equalToConstant: 150),
            timeTemperatureCollectionView.leftAnchor.constraint(equalTo: mainScrollView.leftAnchor, constant: 0),
            timeTemperatureCollectionView.rightAnchor.constraint(equalTo: mainScrollView.rightAnchor, constant: 0),
            timeTemperatureCollectionView.bottomAnchor.constraint(equalTo: daysTemperatureTableView.topAnchor, constant: -1),
            timeTemperatureCollectionView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor)
        ])
    }
    
    private func setConstraintsDaysTemperatureTableView() {
        daysTemperatureTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            daysTemperatureTableView.heightAnchor.constraint(equalToConstant: 7 * 45),
            daysTemperatureTableView.leftAnchor.constraint(equalTo: mainScrollView.leftAnchor, constant: 0),
            daysTemperatureTableView.rightAnchor.constraint(equalTo: mainScrollView.rightAnchor, constant: -16),
            daysTemperatureTableView.bottomAnchor.constraint(equalTo: moreDescriptionTableView.topAnchor, constant: -1)
        ])
    }
    
    private func setConstraintsMoreDescriptionTableView() {
        moreDescriptionTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            moreDescriptionTableView.heightAnchor.constraint(equalToConstant: 8 * 65),
            moreDescriptionTableView.leftAnchor.constraint(equalTo: mainScrollView.leftAnchor, constant: 0),
            moreDescriptionTableView.rightAnchor.constraint(equalTo: mainScrollView.rightAnchor, constant: -16),
            moreDescriptionTableView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor, constant: 0)
        ])
    }
    
    private func showAlert() {
        let alert = UIAlertController(
            title: "Oooops",
            message: "Check your internet connection",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )
        
        present(alert, animated: true)
    }
}

extension MainViewController {
    private func getWeatherForecast() {
        NetworkManager.shared.fetchWeatherForecastByLocation(url: NetworkManager.shared.locationUrl) { result in
            switch result {
            case .success(let weatherForecast):
                self.weatherForecast = weatherForecast
                self.updateHeaderLabels()
                self.timeTemperatureCollectionView.reloadData()
                self.daysTemperatureTableView.reloadData()
                self.moreDescriptionTableView.reloadData() // Объединить всё в один метод по обновлению)
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self.showAlert()
                }
            }
        }
    }
}

extension Double {
    var getRound: Int {
        Int(self.rounded(.up))
    }
}

extension MainViewController: CityListTableViewControllerDelegate {
    func setWeatherForecast(_ forecast: WeatherForecast) {
        weatherForecast = forecast
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: forecast.lat ?? 0, longitude: forecast.lon ?? 0)

        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) -> Void in
            placemarks?.forEach { (placemark) in
                if let city = placemark.locality {
                    self.cityLabel.text = city
                } else {
                    self.cityLabel.text = "Near search place"
                }
            }
        })
        
        updateHeaderLabels()
        timeTemperatureCollectionView.reloadData()
        daysTemperatureTableView.reloadData()
        moreDescriptionTableView.reloadData() // Объединить всё в один метод по обновлению)
    }
    
    func rememberCityList(_ weatherForecasts: [WeatherForecast]) {
        cityList = weatherForecasts
    }
}

extension UIView {
    func addVerticalGradientLayer(topColor: UIColor, bottomColor: UIColor) {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [topColor.cgColor, bottomColor.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        layer.insertSublayer(gradient, at: 0)
    }
}
