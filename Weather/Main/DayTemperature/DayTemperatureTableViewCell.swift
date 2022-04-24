//
//  DayTemperatureTableViewCell.swift
//  Weather
//
//  Created by Анатолий Миронов on 26.03.2022.
//

import UIKit

class DayTemperatureTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let cellID = "DayTemperatureID"
    var presenter: DayTemperatureCellProtocol!
    
    // MARK: - Views
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
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews(dayLabel, weatherPicture, maxTemperature, minTemperature)
        setAllConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: \(coder) has not been implemented")
    }
    
    // MARK: - Configure Cell
    func configure() {
        self.layer.borderWidth = 0
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        dayLabel.text = presenter.day
        maxTemperature.text = presenter.maxTemp
        minTemperature.text = presenter.minTemp
        
        presenter.getImage { imageData in
            self.weatherPicture.image = UIImage(data: imageData)
        }
    }
    
    // MARK: - Constraints
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
