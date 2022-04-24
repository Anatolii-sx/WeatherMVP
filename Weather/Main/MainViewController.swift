//
//  MainViewController.swift
//  Weather
//
//  Created by Анатолий Миронов on 23.03.2022.
//

import UIKit
import CoreLocation

// MARK: - MainViewControllerProtocol (Connection Presenter -> View)
protocol MainViewControllerProtocol: AnyObject {
    func getPlaceName(_ name: String)
    func updateViews()
    func showError(message: String)
}

protocol CityListTableViewControllerDelegate {
    func setWeatherForecast(_ forecast: WeatherForecast)
    func rememberCityList(_ weatherForecasts: [WeatherForecast])
}

class MainViewController: UIViewController {
    
    // MARK: - Properties
    private var presenter: MainPresenter!
    
    private let primaryColor = UIColor(red: 1/255, green: 255/255, blue: 255/255, alpha: 0.4)
    private let secondaryColor = UIColor(red: 25/255, green: 33/255, blue: 78/255, alpha: 0.4)
    
    private lazy var mainScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var firstDashView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.4751085639, green: 0.6077432632, blue: 0.6271204352, alpha: 1)
        return view
    }()
    
    private lazy var secondDashView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.4751085639, green: 0.6077432632, blue: 0.6271204352, alpha: 1)
        return view
    }()
    
    private lazy var thirdDashView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.4751085639, green: 0.6077432632, blue: 0.6271204352, alpha: 1)
        return view
    }()
    
    // MARK: - Header Views
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            placeLabel,
            weatherStatusLabel,
            temperatureLabel
        ])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        return stackView
    }()
    
    private lazy var placeLabel: UILabel = {
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
    
    // MARK: - Main Views (Temperature By Time)
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

    // MARK: - Main Views (Temperature By Days)
    private lazy var daysTemperatureTableView: UITableView = {
        let  tableView = UITableView()
        tableView.register(DayTemperatureTableViewCell.self, forCellReuseIdentifier: DayTemperatureTableViewCell.cellID)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    // MARK: - Bottom Views (Description)
    private lazy var descriptionTableView: UITableView = {
        let  tableView = UITableView()
        tableView.register(DescriptionTableViewCell.self, forCellReuseIdentifier: DescriptionTableViewCell.cellID)
        tableView.backgroundColor = .clear
        tableView.separatorColor = .white
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = false
        tableView.rowHeight = 65
        return tableView
    }()
    
    // MARK: - Methods of ViewController's Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MainPresenter(view: self)
        presenter.getCurrentPlace()
        addAllSubviews()
        setAllConstraints()
        setToolbar()
        setDelegatesAndDataSources()
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
    }
    
    // MARK: - Method of Adding Subviews
    private func addAllSubviews() {
        view.addSubview(mainScrollView)
        mainScrollView.addSubviews(
            headerStackView,
            firstDashView,
            timeTemperatureCollectionView,
            secondDashView,
            daysTemperatureTableView,
            thirdDashView,
            descriptionTableView
        )
    }
    
    // MARK: - Method of setting Delegates And DataSources
    private func setDelegatesAndDataSources() {
        timeTemperatureCollectionView.delegate = self
        timeTemperatureCollectionView.dataSource = self
        daysTemperatureTableView.delegate = self
        daysTemperatureTableView.dataSource = self
        descriptionTableView.delegate = self
        descriptionTableView.dataSource = self
    }
    
    // MARK: - Toolbar
    private func setToolbar() {
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
        
        navigationController?.isToolbarHidden = false
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.toolbar.barTintColor = .black
        navigationController?.toolbar.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)

        toolbarItems = [locationButton, flexibleSpace, listButton]
    }
    
    @objc private func listButtonTapped() {
        let cityListVC = PlaceListTableViewController()
        cityListVC.delegate = self
        cityListVC.presenter = PlaceListPresenter(view: cityListVC)
        cityListVC.presenter.setListOfWeatherForecasts(presenter.forecastList)
        
        let navController = UINavigationController(rootViewController: cityListVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
        toolbarItems?.first?.image = UIImage(systemName: "location")
    }
    
    @objc private func locationButtonTapped() {
        presenter.getCurrentPlace()
        toolbarItems?.first?.image = UIImage(systemName: "location.fill")
    }
    
    // MARK: - Other Private Methods
    private func updateHeaderLabels() {
        weatherStatusLabel.text = presenter.weatherStatus
        temperatureLabel.text = presenter.temperature
    }
    
    // MARK: - Constraints
    private func setAllConstraints() {
        setConstraintsScrollView()
        setConstraintsHeaderStackView()
        setConstraintsFirstDashView()
        setConstraintsTimeTemperatureCollectionView()
        setConstraintsSecondDashView()
        setConstraintsDaysTemperatureTableView()
        setConstraintsThirdDashView()
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
    
    private func setConstraintsFirstDashView() {
        firstDashView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            firstDashView.heightAnchor.constraint(equalToConstant: 1),
            firstDashView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor),
            firstDashView.topAnchor.constraint(equalTo: timeTemperatureCollectionView.topAnchor, constant: 10)
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
    
    private func setConstraintsSecondDashView() {
        secondDashView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            secondDashView.heightAnchor.constraint(equalToConstant: 1),
            secondDashView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor),
            secondDashView.topAnchor.constraint(equalTo: timeTemperatureCollectionView.bottomAnchor, constant: -15)
        ])
    }
    
    private func setConstraintsDaysTemperatureTableView() {
        daysTemperatureTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            daysTemperatureTableView.heightAnchor.constraint(equalToConstant: 7 * 45),
            daysTemperatureTableView.leftAnchor.constraint(equalTo: mainScrollView.leftAnchor, constant: 0),
            daysTemperatureTableView.rightAnchor.constraint(equalTo: mainScrollView.rightAnchor, constant: -16),
            daysTemperatureTableView.bottomAnchor.constraint(equalTo: descriptionTableView.topAnchor, constant: -1)
        ])
    }
    
    private func setConstraintsThirdDashView() {
        thirdDashView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thirdDashView.heightAnchor.constraint(equalToConstant: 1),
            thirdDashView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor),
            thirdDashView.topAnchor.constraint(equalTo: daysTemperatureTableView.bottomAnchor, constant: 0)
        ])
    }
    
    private func setConstraintsMoreDescriptionTableView() {
        descriptionTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionTableView.heightAnchor.constraint(equalToConstant: 8 * 65),
            descriptionTableView.leftAnchor.constraint(equalTo: mainScrollView.leftAnchor, constant: 0),
            descriptionTableView.rightAnchor.constraint(equalTo: mainScrollView.rightAnchor, constant: -16),
            descriptionTableView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor, constant: 0)
        ])
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate (Temperature By Time)
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.numberOfItemsInSectionCollectionView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeTemperatureCollectionViewCell.cellID, for: indexPath) as? TimeTemperatureCollectionViewCell else { return UICollectionViewCell() }
        if let _ = presenter.weatherForecast?.hourly {
            cell.presenter = presenter.cellTimeTemperaturePresenter(at: indexPath)
            cell.configure()
        }
        return cell
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate (Temperature By Days and Description)
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        
        if tableView == daysTemperatureTableView {
            count = presenter.numberOfRowsDailyTableViewSection
        } else if tableView == descriptionTableView {
            count = presenter.numberOfRowsDescriptionTableViewSection
        }

        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        // Days
        if tableView == daysTemperatureTableView {
            guard let dayTemperatureCell = daysTemperatureTableView.dequeueReusableCell(withIdentifier: DayTemperatureTableViewCell.cellID) as? DayTemperatureTableViewCell else { return UITableViewCell() }
            if let _ = presenter.weatherForecast?.daily {
                dayTemperatureCell.presenter = presenter.cellDayTemperaturePresenter(at: indexPath)
                dayTemperatureCell.configure()
            }
            
            cell = dayTemperatureCell
            
        // Description Table View
        } else if tableView == descriptionTableView {
            guard let moreDescriptionCell = descriptionTableView.dequeueReusableCell(withIdentifier: DescriptionTableViewCell.cellID) as? DescriptionTableViewCell else { return UITableViewCell() }
            moreDescriptionCell.presenter = presenter.cellDescriptionPresenter(at: indexPath)
            moreDescriptionCell.configure()
            cell = moreDescriptionCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - CityListTableViewControllerDelegate
extension MainViewController: CityListTableViewControllerDelegate {
    func setWeatherForecast(_ forecast: WeatherForecast) {
        presenter.weatherForecast = forecast
        
        GeoCoder.shared.getPlace(latitude: forecast.lat ?? 0, longitude: forecast.lon ?? 0) { place in
            self.placeLabel.text = place
        }
        
        updateAllViews()
    }
    
    func updateAllViews() {
        updateHeaderLabels()
        timeTemperatureCollectionView.reloadData()
        daysTemperatureTableView.reloadData()
        descriptionTableView.reloadData()
    }
    
    func rememberCityList(_ weatherForecasts: [WeatherForecast]) {
        presenter.forecastList = weatherForecasts
    }
}

// MARK: - Alert Controller
extension MainViewController {
    func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Oooops",
            message: message,
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

// MARK: - Realization MainViewControllerProtocol Methods (Connection Presenter -> View)
extension MainViewController: MainViewControllerProtocol {
    func getPlaceName(_ name: String) {
        placeLabel.text = name
    }
    
    func updateViews() {
        updateAllViews()
    }
    
    func showError(message: String) {
        showAlert(message: message)
    }
}
