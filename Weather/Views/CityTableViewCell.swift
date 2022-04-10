//
//  CityTableViewCell.swift
//  Weather
//
//  Created by Анатолий Миронов on 03.04.2022.
//

import UIKit
import CoreLocation

class CityTableViewCell: UITableViewCell {
    
    static let cellID = "CityID"
    
    var isCurrentDestination = false
    
    private lazy var titleLabel: UILabel =  {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = .black
        return titleLabel
    }()
    
    private lazy var timeLabel: UILabel =  {
        let timeLabel = UILabel()
        timeLabel.font = .systemFont(ofSize: 15, weight: .medium)
        timeLabel.textColor = .black
        return timeLabel
    }()
    
    private lazy var locationImage: UIImageView = {
        let currentDestinationImage = UIImageView()
        currentDestinationImage.image = UIImage(systemName: "location.fill")
        return currentDestinationImage
    }()
    
    private lazy var temperatureLabel: UILabel =  {
        let temperatureLabel = UILabel()
        temperatureLabel.font = .systemFont(ofSize: 30, weight: .medium)
        temperatureLabel.textColor = .black
        return temperatureLabel
    }()
    
    

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews(titleLabel, timeLabel, locationImage, temperatureLabel)
        setAllConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: \(coder) has not been implemented")
    }
    
    private func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
    private func getFormat(time: Int, timezone: String) -> String {
        
        let time = Double(time)
        let date = "\(Date(timeIntervalSince1970: time))"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        guard let theDate = dateFormatter.date(from: date) else { return "" }

        let newDateFormatter = DateFormatter()
        newDateFormatter.timeZone = TimeZone(identifier: timezone)
        newDateFormatter.dateFormat = "HH:mm"
        
        return newDateFormatter.string(from: theDate)
    }
    
    // MARK: - Configure Cell
    func configure(forecast: WeatherForecast, isLocationImageHidden: Bool) {
        locationImage.isHidden = isLocationImageHidden
        
        temperatureLabel.text = "\(forecast.current?.temp?.getRound ?? 0 )º"
        timeLabel.text = getFormat(time: forecast.current?.dt ?? 0, timezone: forecast.timezone ?? "")
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: forecast.lat ?? 0, longitude: forecast.lon ?? 0)

        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) -> Void in
            placemarks?.forEach { (placemark) in
                if let city = placemark.locality {
                    self.titleLabel.text = city
                }
            }
        })
        
    }
    
    private func setAllConstraints() {
        setConstraintsForTitleLabel()
        setConstraintsForTimeLabel()
        setConstraintsForLocationImage()
        setConstraintsForTemperatureLabel()
    }

    private func setConstraintsForTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 5),
            titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            titleLabel.rightAnchor.constraint(equalTo: temperatureLabel.leftAnchor, constant: -20),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
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
    
    private func setConstraintsForTemperatureLabel() {
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            temperatureLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            temperatureLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
            temperatureLabel.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    
}
