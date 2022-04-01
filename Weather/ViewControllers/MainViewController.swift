//
//  MainViewController.swift
//  Weather
//
//  Created by Анатолий Миронов on 23.03.2022.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
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
            ["uv index": weatherForecast?.current?.uvi?.getRound ?? 0],
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
        newDateFormatter.dateFormat = "HH:mm"
        
        return newDateFormatter.string(from: theDate)
    }
    
    private lazy var mainScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .yellow
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
        stackView.backgroundColor = .red
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
        weatherStatusLabel.font = .systemFont(ofSize: 24, weight: .medium)
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
        layout.itemSize = CGSize(width: 70, height: 150)
        return layout
    }()
    
    private lazy var timeTemperatureCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: timeTemperatureCollectionViewFlowLayout)
        collectionView.register(TimeTemperatureCollectionViewCell.self, forCellWithReuseIdentifier: TimeTemperatureCollectionViewCell.cellID)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .brown
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
        
        getWeatherForecast()
       
        view.backgroundColor = .purple
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
    
    private func addSubviewsIntoMainScrollView(_ views: UIView...) {
        views.forEach { mainScrollView.addSubview($0) }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        weatherForecast?.hourly?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeTemperatureCollectionViewCell.cellID, for: indexPath) as? TimeTemperatureCollectionViewCell else { return UICollectionViewCell() }
        if let hourlyForecasts = weatherForecast?.hourly {
            cell.configure(forecast: hourlyForecasts[indexPath.row])
        }
        cell.backgroundColor = .gray
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
                dayTemperatureCell.configure(forecast: dailyForecasts[indexPath.row])
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
        cityLabel.text = weatherForecast?.timezone ?? ""
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
            headerStackView.heightAnchor.constraint(equalToConstant: 150),
            headerStackView.topAnchor.constraint(equalTo: mainScrollView.topAnchor, constant: 0),
            headerStackView.leftAnchor.constraint(equalTo: mainScrollView.leftAnchor, constant: 0),
            headerStackView.rightAnchor.constraint(equalTo: mainScrollView.rightAnchor, constant: 0),
            headerStackView.bottomAnchor.constraint(equalTo: timeTemperatureCollectionView.topAnchor, constant: -16),
            headerStackView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor)
        ])
    }
    
    private func setConstraintsTimeTemperatureCollectionView() {
        timeTemperatureCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeTemperatureCollectionView.heightAnchor.constraint(equalToConstant: 150),
            timeTemperatureCollectionView.leftAnchor.constraint(equalTo: mainScrollView.leftAnchor, constant: 0),
            timeTemperatureCollectionView.rightAnchor.constraint(equalTo: mainScrollView.rightAnchor, constant: 0),
            timeTemperatureCollectionView.bottomAnchor.constraint(equalTo: daysTemperatureTableView.topAnchor, constant: -16),
            timeTemperatureCollectionView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor)
        ])
    }
    
    private func setConstraintsDaysTemperatureTableView() {
        daysTemperatureTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            daysTemperatureTableView.heightAnchor.constraint(equalToConstant: 7 * 45),
            daysTemperatureTableView.leftAnchor.constraint(equalTo: mainScrollView.leftAnchor, constant: 0),
            daysTemperatureTableView.rightAnchor.constraint(equalTo: mainScrollView.rightAnchor, constant: 0),
            daysTemperatureTableView.bottomAnchor.constraint(equalTo: moreDescriptionTableView.topAnchor, constant: -16),
            daysTemperatureTableView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor)
        ])
    }
    
    private func setConstraintsMoreDescriptionTableView() {
        moreDescriptionTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            moreDescriptionTableView.heightAnchor.constraint(equalToConstant: 8 * 65),
            moreDescriptionTableView.leftAnchor.constraint(equalTo: mainScrollView.leftAnchor, constant: 0),
            moreDescriptionTableView.rightAnchor.constraint(equalTo: mainScrollView.rightAnchor, constant: 0),
            moreDescriptionTableView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor, constant: 0),
            moreDescriptionTableView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor)
        ])
    }
}

extension MainViewController {
    private func getWeatherForecast() {
        NetworkManager.shared.fetchWeatherForecast(url: NetworkManager.shared.url) { result in
            switch result {
            case .success(let weatherForecast):
                self.weatherForecast = weatherForecast
                self.updateHeaderLabels()
                self.timeTemperatureCollectionView.reloadData()
                self.daysTemperatureTableView.reloadData()
                self.moreDescriptionTableView.reloadData() // Объединить всё в один метод по обновлению)
                print(weatherForecast)
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension Double {
    var getRound: Int {
        Int(self.rounded(.up))
    }
}

