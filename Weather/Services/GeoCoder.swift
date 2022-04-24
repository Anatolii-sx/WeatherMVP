//
//  GeoCoder.swift
//  Weather
//
//  Created by Анатолий Миронов on 12.04.2022.
//

import Foundation
import CoreLocation

class GeoCoder {
    static let shared = GeoCoder()
    
    private init() {}
    
    func getPlace(latitude: Double, longitude: Double, completion: @escaping(String) -> Void) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)

        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) -> Void in
            placemarks?.forEach { placemark in
                if let place = placemark.locality {
                    completion(place)
                } else {
                    completion("Near search place")
                }
            }
        })
    }
}
