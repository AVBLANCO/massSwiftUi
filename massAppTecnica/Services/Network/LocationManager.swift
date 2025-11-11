//
//  LocationManager.swift
//  massAppTecnica
//
//  Created by Victor Manuel Blanco Mancera on 6/11/25.
//

import Foundation
import CoreLocation
import MapKit

/// Manejador de Ubicación (CLLocationManager)
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var locationStatus: CLAuthorizationStatus?

    var locationStatusText: String {
        switch locationStatus {
        case .notDetermined: return "Buscando ubicación..."
        case .authorizedWhenInUse, .authorizedAlways:
            if let loc = location {
                return "Ubicación GPS: \(loc.coordinate.latitude.formatted(.number.precision(.fractionLength(4)))), \(loc.coordinate.longitude.formatted(.number.precision(.fractionLength(4))))"
            }
            return "Obteniendo ubicación..."
        case .denied, .restricted: return "Permiso de ubicación denegado. Active en Ajustes."
        default: return "Cargando..."
        }
    }

    override init() {
        super.init()
        manager.delegate = self
        // Configuración adicional: precisión
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    // MARK: - Delegate Methods

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.first {
            if location == nil || newLocation.distance(from: location!) > 10 {
                location = newLocation
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error de localización: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationStatus = manager.authorizationStatus
        if locationStatus == .authorizedWhenInUse || locationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
}
