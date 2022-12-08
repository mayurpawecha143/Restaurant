//
//  LocationManager.swift
//  RestaurantSearch
//
//  Created by Mayur Pawecha on 12/2/22.
//

import Foundation
import CoreLocation

protocol LocationManagerable {
    var newLocation: ((Result<CLLocation, Error>) -> Void)? { get set }
    func requestLocationAuthorization()
}

final class LocationManager: NSObject, LocationManagerable {
        
    private let manager: CLLocationManager
    
    init(manager: CLLocationManager = .init()) {
        self.manager = manager
        super.init()
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    var newLocation: ((Result<CLLocation, Error>) -> Void)?
    
    var status: CLAuthorizationStatus {
        return manager.authorizationStatus
    }
        
    func requestLocationAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
        
    func getLocation() {
        if CLLocationManager.locationServicesEnabled() {
            manager.requestLocation()
            manager.startUpdatingLocation()
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        newLocation?(.failure(error))
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        if let location = locations.sorted(by: {$0.timestamp > $1.timestamp}).first {
            newLocation?(.success(location))
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            getLocation()
        }
    }
}
