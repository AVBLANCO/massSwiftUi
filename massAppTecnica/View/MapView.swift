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
            // Usamos ZStack para asegurar que el fondo oscuro cubra toda el área.
            ZStack {
                Color.maasDark.ignoresSafeArea()

                VStack {
                    // El mapa ocupa la mayor parte de la pantalla.
                    Map(coordinateRegion: $region, annotationItems: stops, annotationContent: { stop in
                        MapMarker(coordinate: stop.coordinate, tint: .maasPrimary) // Marcador en verde principal
                    })
                    .edgesIgnoringSafeArea(.all)

                    // --- Overlay de información (Estilizado) ---
                    VStack {
                        Text("Paraderos Cercanos (Max. 1000m)")
                            .font(.titleMedium)
                            .fontWeight(.bold)
                            .foregroundColor(.maasPrimary) // Título en verde principal
                            .padding(.top, 10)

                        Text(locationManager.locationStatusText)
                            .font(.caption)
                            .foregroundColor(.gray)

                        // Si hay paradas, muestra el conteo.
                        if !stops.isEmpty {
                            Text("\(stops.count) paraderos encontrados.")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    // Fondo oscuro y redondeado para el contenedor de información
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.opacity(0.7))
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: -2)
                    )
                    .padding([.horizontal, .bottom]) // Separación de los bordes
                    .offset(y: -50) // Mueve la caja un poco hacia arriba del borde inferior
                }
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
            .navigationTitle("Mapa de Rutas")
            .toolbarColorScheme(.dark, for: .navigationBar) // Barra de navegación oscura
        }
    }
}

extension MKPointAnnotation: Identifiable {
    public var id: String {
        return UUID().uuidString
    }
}
