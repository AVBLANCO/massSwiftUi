//
//  MapView.swift
//  massAppTecnica
//
//  Created by Victor Manuel Blanco Mancera on 6/11/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 4.6097, longitude: -74.0817),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    @State private var stops: [MKPointAnnotation] = []

    // Inyectamos el servicio de red para obtener las paradas
    private let networkManager = NetworkManager()

    var body: some View {
        NavigationView {
            VStack {
                // El error de Identifiable se resuelve con la extensión en MapAnnotationExtension.swift
                Map(coordinateRegion: $region, annotationItems: stops, annotationContent: { stop in
                    // MapMarker requiere que 'stop' sea Identifiable
                    MapMarker(coordinate: stop.coordinate, tint: .red)
                })
                .edgesIgnoringSafeArea(.all)

                // Overlay de información
                VStack {
                    Text("Paraderos Cercanos (Max. 1000m)")
                        .font(.headline)
                        .padding(.top, 8)
                    Text(locationManager.locationStatusText)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 10)
                .background(Color.white.opacity(0.95))
            }
            .onAppear {
                locationManager.requestLocation()
            }
            .onChange(of: locationManager.location) { newLocation in
                if let location = newLocation {
                    withAnimation {
                        region.center = location.coordinate
                    }

                    // Llamar a la API de OpenTripPlanner
                    Task {
                        do {
                            self.stops = try await networkManager.fetchNearbyStops(
                                latitude: location.coordinate.latitude,
                                longitude: location.coordinate.longitude
                            )
                        } catch {
                            print("Error al obtener paraderos: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .navigationTitle("Mapa")
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        }
    }
}

extension MKPointAnnotation: Identifiable {
    public var id: String {
        return UUID().uuidString
    }
}
