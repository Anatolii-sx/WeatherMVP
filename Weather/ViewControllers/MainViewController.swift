//
//  MainViewController.swift
//  Weather
//
//  Created by Анатолий Миронов on 23.03.2022.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    private lazy var mainScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .yellow
        return scrollView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
                headerStackView,
                timeTemperatureCollectionView,
                daysTemperatureTableView,
                moreDescriptionTableView
            ])
        stackView.axis = .vertical
//        stackView.distribution = .equalSpacing
        stackView.backgroundColor = .blue
        return stackView
    }()
    
    // MARK: - Header
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
        cityLabel.text = "Moscow"
        cityLabel.textAlignment = .center
        cityLabel.font = .systemFont(ofSize: 32, weight: .medium)
        cityLabel.textColor = .white
        return cityLabel
    }()
    
    private lazy var weatherStatusLabel: UILabel = {
        let weatherStatusLabel = UILabel()
        weatherStatusLabel.text = "Rain"
        weatherStatusLabel.textAlignment = .center
        weatherStatusLabel.font = .systemFont(ofSize: 24, weight: .medium)
        weatherStatusLabel.textColor = .white
        return weatherStatusLabel
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let temperatureLabel = UILabel()
        temperatureLabel.text = "5º"
        temperatureLabel.textAlignment = .center
        temperatureLabel.font = .systemFont(ofSize: 40, weight: .medium)
        temperatureLabel.textColor = .white
        return temperatureLabel
    }()
    
    // MARK: - Main
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
       
        view.backgroundColor = .purple
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(mainStackView)
        setAllConstraints()
        
        timeTemperatureCollectionView.delegate = self
        timeTemperatureCollectionView.dataSource = self
        
        daysTemperatureTableView.delegate = self
        daysTemperatureTableView.dataSource = self
        
        moreDescriptionTableView.delegate = self
        moreDescriptionTableView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeTemperatureCollectionViewCell.cellID, for: indexPath) as? TimeTemperatureCollectionViewCell else { return UICollectionViewCell() }
        cell.configure()
        cell.backgroundColor = .gray
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        
        if tableView == daysTemperatureTableView {
            count = 7
        } else if tableView == moreDescriptionTableView {
            count = 10
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if tableView == daysTemperatureTableView {
            guard let dayTemperatureCell = daysTemperatureTableView.dequeueReusableCell(withIdentifier: DayTemperatureTableViewCell.cellID) as? DayTemperatureTableViewCell else { return UITableViewCell() }
            dayTemperatureCell.configure()
            cell = dayTemperatureCell
        } else if tableView == moreDescriptionTableView {
            guard let moreDescriptionCell = moreDescriptionTableView.dequeueReusableCell(withIdentifier: MoreDescriptionTableViewCell.cellID) as? MoreDescriptionTableViewCell else { return UITableViewCell() }
            moreDescriptionCell.configure()
            cell = moreDescriptionCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func setAllConstraints() {
        setConstraintsForScrollView()
        setConstraintsForMainStackView()
        setHeightConstraintForTimeTemperatureCollectionView()
        setHeightConstraintForDaysTemperatureTableView()
        setHeightConstraintForMoreDescriptionTableView()
    }
    
    private func setConstraintsForScrollView() {
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            mainScrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            mainScrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            mainScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
    }
    
    private func setConstraintsForMainStackView() {
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: mainScrollView.topAnchor, constant: 0),
            mainStackView.leftAnchor.constraint(equalTo: mainScrollView.leftAnchor, constant: 0),
            mainStackView.rightAnchor.constraint(equalTo: mainScrollView.rightAnchor, constant: 0),
            mainStackView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor, constant: 0),
            mainStackView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor)
        ])
    }
    
    private func setHeightConstraintForTimeTemperatureCollectionView() {
        timeTemperatureCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeTemperatureCollectionView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func setHeightConstraintForDaysTemperatureTableView() {
        daysTemperatureTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            daysTemperatureTableView.heightAnchor.constraint(equalToConstant: 7 * 45)
        ])
    }
    
    private func setHeightConstraintForMoreDescriptionTableView() {
        moreDescriptionTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            moreDescriptionTableView.heightAnchor.constraint(equalToConstant: 10 * 65),
            moreDescriptionTableView.rightAnchor.constraint(equalTo: mainStackView.rightAnchor, constant: -16)
        ])
    }
}

