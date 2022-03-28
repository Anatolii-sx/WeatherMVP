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
        dayLabel.font = .systemFont(ofSize: 18, weight: .medium)
        dayLabel.textColor = .black
        return dayLabel
    }()
    
    private lazy var weatherPicture: UIImageView =  {
        let weatherPicture = UIImageView()
        return weatherPicture
    }()
    
    private lazy var maxTemperatureDay: UILabel =  {
        let maxTemperatureDay = UILabel()
        maxTemperatureDay.font = .systemFont(ofSize: 18, weight: .medium)
        maxTemperatureDay.textColor = .black
        return maxTemperatureDay
    }()
    
    private lazy var minTemperatureNight: UILabel =  {
        let minTemperatureNight = UILabel()
        minTemperatureNight.font = .systemFont(ofSize: 18, weight: .medium)
        minTemperatureNight.textColor = .black
        return minTemperatureNight
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews(dayLabel, weatherPicture, maxTemperatureDay, minTemperatureNight)
        setAllConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: \(coder) has not been implemented")
    }
    
    func configure() {
        self.layer.borderWidth = 0
        
        dayLabel.text = "Sunday"
        weatherPicture.image = UIImage(systemName: "cloud")
        maxTemperatureDay.text = "10"
        minTemperatureNight.text = "-5"
    }
    
    private func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
    private func setAllConstraints() {
        setConstraintsForDayLabel()
        setConstraintsForWeatherPicture()
        setConstraintsForMaxTemperatureDay()
        setConstraintsForMinTemperatureNight()
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
            weatherPicture.widthAnchor.constraint(equalToConstant: 32),
            weatherPicture.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setConstraintsForMaxTemperatureDay() {
        maxTemperatureDay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            maxTemperatureDay.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            maxTemperatureDay.rightAnchor.constraint(equalTo: minTemperatureNight.leftAnchor, constant: -24)
        ])
    }
    
    private func setConstraintsForMinTemperatureNight() {
        minTemperatureNight.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            minTemperatureNight.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            minTemperatureNight.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16)
        ])
    }
}
