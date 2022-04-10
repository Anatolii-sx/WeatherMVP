//
//  City.swift
//  Weather
//
//  Created by Анатолий Миронов on 05.04.2022.
//

import Foundation

struct City: Decodable {
    let coord: Coordinate
    let name: String?
}

struct Coordinate: Decodable {
    let lat: Double?
    let lon: Double?
}


