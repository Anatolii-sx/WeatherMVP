//
//  DayTemperatureTableViewCell.swift
//  Weather
//
//  Created by Анатолий Миронов on 26.03.2022.
//

import UIKit

class DayTemperatureTableViewCell: UITableViewCell {
    static let cellID = "DayTemperatureID"
    
    private lazy var dayLabel: UILabel =  {
        let dayLabel = UILabel()
        dayLabel.font = .systemFont(ofSize: 20, weight: .medium)
        dayLabel.textColor = .white
        return dayLabel
    }()
    
    private lazy var weatherPicture: UIImageView =  {
        let weatherPicture = UIImageView()
        return weatherPicture
    }()
    
    private lazy var maxTemperature: UILabel =  {
        let maxTemperature = UILabel()
        maxTemperature.font = .systemFont(ofSize: 20, weight: .medium)
        maxTemperature.textColor = .white
        maxTemperature.textAlignment = .right
        return maxTemperature
    }()
    
    private lazy var minTemperature: UILabel =  {
        let minTemperature = UILabel()
        minTemperature.font = .systemFont(ofSize: 20, weight: .medium)
        minTemperature.textColor = .white
        minTemperature.textAlignment = .right
        return minTemperature
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews(dayLabel, weatherPicture, maxTemperature, minTemperature)
        setAllConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: \(coder) has not been implemented")
    }
    
    func configure(forecast: Daily, timezone: String) {
        self.layer.borderWidth = 0
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        dayLabel.text = getFormat(dayTemperature: forecast.dt ?? 0, timezone: timezone)
        
        if let maxTemp = forecast.temp?.max, let minTemp = forecast.temp?.min {
            maxTemperature.text = "\(maxTemp.getRound)"
            minTemperature.text = "\(minTemp.getRound)"
        }
        
        NetworkManager.shared.fetchWeatherImage(icon: forecast.weather?.first?.icon ?? "") { imageData in
            if let imageData = imageData {
                self.weatherPicture.image = UIImage(data: imageData)
            }
        }
    }
    
    private func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
    private func getFormat(dayTemperature: Int, timezone: String) -> String {
        
        let temperature = Double(dayTemperature)
        let date = "\(Date(timeIntervalSince1970: temperature))"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        guard let theDate = dateFormatter.date(from: date) else { return "" }

        let newDateFormatter = DateFormatter()
        newDateFormatter.timeZone = TimeZone(identifier: timezone)
        newDateFormatter.dateFormat = "EEEE"
        
        return newDateFormatter.string(from: theDate)
    }
    
    private func setAllConstraints() {
        setConstraintsForDayLabel()
        setConstraintsForWeatherPicture()
        setConstraintsForMaxTemperature()
        setConstraintsForMinTemperature()
    }

    private func setConstraintsForDayLabel() {
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dayLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            dayLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16)
        ])
    }
    
    private func setConstraintsForWeatherPicture() {
        weatherPicture.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            weatherPicture.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            weatherPicture.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            weatherPicture.widthAnchor.constraint(equalToConstant: 40),
            weatherPicture.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setConstraintsForMaxTemperature() {
        maxTemperature.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            maxTemperature.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            maxTemperature.widthAnchor.constraint(equalToConstant: 30),
            maxTemperature.rightAnchor.constraint(equalTo: minTemperature.leftAnchor, constant: -24)
        ])
    }
    
    private func setConstraintsForMinTemperature() {
        minTemperature.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            minTemperature.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            minTemperature.widthAnchor.constraint(equalToConstant: 30),
            minTemperature.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        ])
    }
}
