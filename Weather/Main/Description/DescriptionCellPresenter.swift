//
//  DescriptionCellPresenter.swift
//  Weather
//
//  Created by Анатолий Миронов on 18.04.2022.
//

import Foundation

protocol DescriptionCellProtocol {
    init(description: [String: Any])
    func getInfo() -> [String: String]
}

class DescriptionCellPresenter: DescriptionCellProtocol {
    private var description: [String : Any]
    
    required init(description: [String : Any]) {
        self.description = description
    }
    
    func getInfo() -> [String: String] {
        var dictionary: [String: String] = [:]
        for (name, text) in description {
            dictionary[name.uppercased()] = "\(text)"
        }
        return dictionary
    }
}
