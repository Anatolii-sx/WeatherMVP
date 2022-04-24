//
//  PlaceTableViewCell.swift
//  Weather
//
//  Created by Анатолий Миронов on 03.04.2022.
//

import UIKit
import CoreLocation

class PlaceTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let cellID = "CityID"
    var isCurrentDestination = false
    var presenter: PlaceCellPresenterProtocol!
    
    // MARK: - Views
    private lazy var titleLabel: UILabel =  {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 28, weight: .medium)
        titleLabel.textColor = .white
        return titleLabel
    }()
    
    private lazy var timeLabel: UILabel =  {
        let timeLabel = UILabel()
        timeLabel.font = .systemFont(ofSize: 15, weight: .regular)
        timeLabel.textColor = .white
        return timeLabel
    }()
    
    private lazy var locationImage: UIImageView = {
        let currentDestinationImage = UIImageView()
        currentDestinationImage.image = UIImage(systemName: "location.fill")
        currentDestinationImage.tintColor = .white
        return currentDestinationImage
    }()
    
    private lazy var temperatureLabel: UILabel =  {
        let temperatureLabel = UILabel()
        temperatureLabel.font = .systemFont(ofSize: 40, weight: .medium)
        temperatureLabel.textColor = .white
        temperatureLabel.textAlignment = .right
        return temperatureLabel
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews(timeLabel, locationImage, titleLabel, temperatureLabel)
        setAllConstraints()
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: \(coder) has not been implemented")
    }
    
    // MARK: - Configure Cell
    func configure(isLocationImageHidden: Bool) {
        locationImage.isHidden = isLocationImageHidden
        selectionStyle = .none
        
        temperatureLabel.text = presenter.temperature
        timeLabel.text = presenter.time
        presenter.getTitle { place in
            self.titleLabel.text = place
        }
    }
    
    // MARK: - Constraints
    private func setAllConstraints() {
        setConstraintsForTitleLabel()
        setConstraintsForTimeLabel()
        setConstraintsForLocationImage()
        setConstraintsForTemperatureLabel()
    }
    
    private func setConstraintsForTimeLabel() {
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            timeLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            timeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 20),
            timeLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    private func setConstraintsForLocationImage() {
        locationImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            locationImage.topAnchor.constraint(equalTo: timeLabel.topAnchor),
            locationImage.leftAnchor.constraint(equalTo: timeLabel.rightAnchor, constant: 10),
            locationImage.widthAnchor.constraint(equalToConstant: 15),
            locationImage.heightAnchor.constraint(equalToConstant: 15)
        ])
    }

    private func setConstraintsForTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 2),
            titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            titleLabel.rightAnchor.constraint(equalTo: temperatureLabel.leftAnchor, constant: -10)
        ])
    }
    
    private func setConstraintsForTemperatureLabel() {
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            temperatureLabel.topAnchor.constraint(equalTo: timeLabel.topAnchor),
            temperatureLabel.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            temperatureLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -28),
            temperatureLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
    }
}
