//
//  ContentViewModel.swift
//  GPS_TEST
//
//  Created by Gerald on 18/2/22.
//

import MapKit
import Foundation

enum MapDetails {
    static let startingLocation = CLLocationCoordinate2D(latitude: 37.0, longitude: 121.1)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
}

final class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var region = MKCoordinateRegion(center: MapDetails.startingLocation, span: MapDetails.defaultSpan)
    
    var locationManager: CLLocationManager?
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            // maybe shouldnt do force unwrapping
            locationManager!.delegate = self
        } else {
            print("show an alert to ask them to turn on location service")
        }
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus{
        
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                print("Your location is restricted likely due to parental controls.")
            case .denied:
                print("You have denied, go to setting to enable.")
            case .authorizedAlways, .authorizedWhenInUse:
                region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            @unknown default:
                break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func retrieveUserLocation() -> CLLocationCoordinate2D {
        if CLLocationManager.locationServicesEnabled() {
            return locationManager?.location!.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        } else {
            print("show an alert to ask them to turn on location service")
            
            return CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        }
        
    }
    
}
