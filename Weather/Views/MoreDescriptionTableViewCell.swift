//
//  MoreDescriptionTableViewCell.swift
//  Weather
//
//  Created by Анатолий Миронов on 26.03.2022.
//

import UIKit

class MoreDescriptionTableViewCell: UITableViewCell {
    
    static let cellID = "MoreDescriptionID"
    
    private lazy var descriptionStackView: UIStackView = {
        let descriptionStackView = UIStackView(arrangedSubviews: [
            titleLabel,
            descriptionLabel
        ])
        descriptionStackView.axis = .vertical
        descriptionStackView.distribution = .equalSpacing
        descriptionStackView.spacing = 5
        return descriptionStackView
    }()

    private lazy var titleLabel: UILabel =  {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = .white
        return titleLabel
    }()
    
    private lazy var descriptionLabel: UILabel =  {
        let descriptionLabel = UILabel()
        descriptionLabel.font = .systemFont(ofSize: 24, weight: .medium)
        descriptionLabel.textColor = .white
        return descriptionLabel
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(descriptionStackView)
        setConstraintsForDescriptionStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: \(coder) has not been implemented")
    }
    
    // MARK: - Configure Cell
    func configure(description: [String: Any]) {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        for (title, text) in description {
            titleLabel.text = title.uppercased()
            descriptionLabel.text = "\(text)"
        }
    }
    
    private func setConstraintsForDescriptionStackView() {
        descriptionStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            descriptionStackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16)
        ])
    }
}
