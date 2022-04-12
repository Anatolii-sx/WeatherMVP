//
//  TimeTemperatureCollectionViewCell.swift
//  Weather
//
//  Created by Анатолий Миронов on 26.03.2022.
//

import UIKit

class TimeTemperatureCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let cellID = "TimeTemperatureID"

    // MARK: - Views
    private lazy var timeLabel: UILabel =  {
        let timeLabel = UILabel()
        timeLabel.textAlignment = .center
        timeLabel.font = .systemFont(ofSize: 18, weight: .medium)
        timeLabel.textColor = .white
        return timeLabel
    }()
    
    private lazy var weatherPicture: UIImageView =  {
        let weatherPicture = UIImageView()
        return weatherPicture
    }()
    
    private lazy var temperatureLabel: UILabel =  {
        let temperatureLabel = UILabel()
        temperatureLabel.textAlignment = .center
        temperatureLabel.font = .systemFont(ofSize: 18, weight: .medium)
        temperatureLabel.textColor = .white
        return temperatureLabel
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(timeLabel, weatherPicture, temperatureLabel)
        setAllConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: \(coder) has not been implemented")
    }
    
    // MARK: - Configure Cell
    func configure(forecast: Hourly, timezone: String) {
        timeLabel.text = Formatter.getFormat(
            unixTime: forecast.dt ?? 0,
            timezone: timezone,
            formatType: Formatter.FormatType.hours.rawValue
        )
        
        if let temperature = forecast.temp {
            temperatureLabel.text = "\(temperature.getRound)º"
        }
        
        NetworkManager.shared.fetchWeatherImage(icon: forecast.weather?.first?.icon ?? "") { imageData in
            if let imageData = imageData {
                self.weatherPicture.image = UIImage(data: imageData)
            }
        }
    }
    
    // MARK: - Constraints
    private func setAllConstraints() {
        setConstraintsForTimeLabel()
        setConstraintsForWeatherPicture()
        setConstraintsForTemperatureLabel()
    }

    private func setConstraintsForTimeLabel() {
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 25),
            timeLabel.bottomAnchor.constraint(equalTo: weatherPicture.topAnchor, constant: -5)
        ])
    }

    private func setConstraintsForWeatherPicture() {
        weatherPicture.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            weatherPicture.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            weatherPicture.bottomAnchor.constraint(equalTo: temperatureLabel.topAnchor, constant: -5),
            weatherPicture.widthAnchor.constraint(equalToConstant: 40),
            weatherPicture.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setConstraintsForTemperatureLabel() {
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            temperatureLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
}
