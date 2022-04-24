//
//  PlaceListTableViewController.swift
//  Weather
//
//  Created by Анатолий Миронов on 03.04.2022.
//

import UIKit
import CoreLocation

// MARK: - PlaceListTableViewProtocol (Connection Presenter -> View)
protocol PlaceListTableViewProtocol: AnyObject {
    func deleteRow(indexPath: IndexPath)
    func insertRow()
    func reloadRows(indexPath: IndexPath)
    func showError(message: String)
}

class PlaceListTableViewController: UITableViewController {
    
    // MARK: - Public Properties
    var delegate: CityListTableViewControllerDelegate!
    
    // MARK: - Private Properties
    private let searchVC = UISearchController(searchResultsController: nil)
    private let primaryColor = UIColor(red: 1/255, green: 255/255, blue: 255/255, alpha: 0.4)
    private let secondaryColor = UIColor(red: 25/255, green: 33/255, blue: 78/255, alpha: 0.4)

    var presenter: PlaceListPresenterProtocol!
    
    // MARK: - Methods of ViewController's Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.getCurrentPlace()
        createSearchBar()
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: PlaceTableViewCell.cellID)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setBackgroundView()
    }
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        CGFloat(presenter.heightForRow)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        presenter.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.getNumberOfRowsInSection(section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        switch indexPath.section {
        case 0:
            guard let placeCell = tableView.dequeueReusableCell(withIdentifier: "CityID", for: indexPath) as? PlaceTableViewCell else { return cell }
            if let _ = presenter.weatherForecastCurrentDestination {
                placeCell.presenter = presenter.cellPresenter(at: indexPath, isZeroSection: true)
                placeCell.configure(isLocationImageHidden: false)
            }
            cell = placeCell
        case 1:
            guard let placeCell = tableView.dequeueReusableCell(withIdentifier: "CityID", for: indexPath) as? PlaceTableViewCell else { return cell }
            placeCell.presenter = presenter.cellPresenter(at: indexPath, isZeroSection: false)
            placeCell.configure(isLocationImageHidden: true)
            cell = placeCell
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath.section {
        case 0:
            if let forecast = presenter.weatherForecastCurrentDestination {
                delegate.setWeatherForecast(forecast)
                delegate.rememberCityList(presenter.weatherForecasts)
            }
        case 1:
            let forecast = presenter.weatherForecasts[indexPath.row]
            delegate.setWeatherForecast(forecast)
            delegate.rememberCityList(presenter.weatherForecasts)
        default:
            break
        }
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            if editingStyle == .delete {
                presenter.deleteButtonTapped(indexPath: indexPath)
            }
        default :
            break
        }
    }
    
    // MARK: - BackgroundView
    private func setBackgroundView() {
        let backgroundView = UIView(frame: tableView.bounds)
        backgroundView.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        tableView.backgroundColor = .black
        tableView.backgroundView = backgroundView
    }
}

// MARK: - SearchBar
extension PlaceListTableViewController: UISearchBarDelegate {
    private func createSearchBar() {
        navigationItem.searchController = searchVC
        searchVC.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        searchVC.searchBar.tintColor = .white
        searchVC.searchBar.searchTextField.leftView?.tintColor = .white
        
        // SearchBar text
        let textFieldInsideUISearchBar = searchVC.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = .white
        textFieldInsideUISearchBar?.font = textFieldInsideUISearchBar?.font?.withSize(18)

        // SearchBar placeholder
        let labelInsideUISearchBar = textFieldInsideUISearchBar?.value(forKey: "placeholderLabel") as? UILabel
        labelInsideUISearchBar?.textColor = .white
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.searchButtonClicked(text: searchBar.text ?? "")
    }
}

// MARK: - Alert Controller
extension PlaceListTableViewController {
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "🙁",
            message: message,
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
}

// MARK: - Realization PlaceListTableViewProtocol Methods (Connection Presenter -> View)
extension PlaceListTableViewController: PlaceListTableViewProtocol {
    
    func deleteRow(indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func insertRow() {
        tableView.insertRows(at: [IndexPath(row: presenter.weatherForecasts.count - 1, section: 1)], with: .automatic)
        searchVC.isActive = false
    }
    
    func reloadRows(indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func showError(message: String) {
        showAlert(message: message)
    }
}
