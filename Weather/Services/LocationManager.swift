//
//  LocationManager.swift
//  Weather
//
//  Created by Анатолий Миронов on 24.04.2022.
//

import Foundation
import CoreLocation

protocol LocationManagerPlaceListDelegate: PlaceListPresenter {
    func didUpdateLocation()
}

protocol LocationManagerMainDelegate: MainPresenter {
    func didUpdateLocation()
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    weak var delegateMain: LocationManagerMainDelegate?
    weak var delegatePlaceList: LocationManagerPlaceListDelegate?
    
    private var locationManager = CLLocationManager()
    
    private override init() {}
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func setLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let first = locations.first else { return }
        NetworkManager.shared.latitude =  String(format: "%.4f", first.coordinate.latitude)
        NetworkManager.shared.longitude = String(format: "%.4f", first.coordinate.longitude)
        locationManager.stopUpdatingLocation()
        
        delegateMain?.didUpdateLocation()
        delegatePlaceList?.didUpdateLocation()
    }
}
