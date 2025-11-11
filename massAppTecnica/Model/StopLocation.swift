//
//  StopLocation.swift
//  massAppTecnica
//
//  Created by Victor Manuel Blanco Mancera on 6/11/25.
//

import Foundation
import SwiftData
import SwiftUI


// MARK: - Modelos de Datos para la API

// Modelo básico para las coordenadas (OpenTripPlanner utiliza Lat,Lon)
struct Coordinate: Encodable {
    let lat: Double
    let lon: Double
}

// Modelo simplificado para la respuesta de la ruta
struct RoutePlan: Decodable {
    let plan: Plan
    let error: ApiError? // Puede ser nulo si no hay error
    struct ApiError: Decodable {
        let id: Int
        let msg: String
    }
}

struct Place: Decodable {
    let name: String? // Puede ser el nombre de una parada o una coordenada
    let lat: Double
    let lon: Double
}

struct Plan: Decodable {
    let date: Date // Usaremos el decodificador personalizado para UNIX timestamp
    let from: Place
    let to: Place
    let itineraries: [Itinerary]
}

struct Itinerary: Decodable, Identifiable {
    var id: UUID = UUID() // Para usar en ForEach
    let duration: Int // Duración en segundos
    let startTime: Date
    let endTime: Date
    let walkDistance: Double
    let legs: [Leg]
    let fare: Fare? // Información de tarifa (opcional)

    struct Fare: Decodable {
        let fare: FareDetails
        struct FareDetails: Decodable {
            let regular: RegularFare?

            struct RegularFare: Decodable {
                let cents: Int
            }
        }
    }

    // Propiedad calculada para formato de duración legible
    var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: TimeInterval(duration)) ?? "N/A"
    }

    var formattedFare: String {
        guard let fareCents = fare?.fare.regular?.cents else {
            return "Tarifa no disponible"
        }
        let fareAmount = Double(fareCents) / 100.0
        return String(format: "$\\(%.2f", fareAmount)
    }
}

struct Leg: Decodable, Identifiable {
    var id: UUID = UUID()
    let startTime: Date
    let endTime: Date
    let duration: Int // Duración de este segmento en segundos
    let distance: Double // Distancia de este segmento en metros
    let mode: String // WALK, BUS, TRAM, SUBWAY, etc.
    let route: String? // ID de la ruta de SITP/TransMilenio (ej: 'M86')
    let routeId: String? // ID interno de la ruta
    let routeShortName: String? // Nombre corto (ej: 'M86')
    let routeLongName: String? // Nombre largo
    let agencyName: String?
    let agencyUrl: String?
    let routeColor: String? // Color de la línea (hex)
    let routeType: Int?

    let from: Place
    let to: Place

    // Polyline es la forma de la ruta en el mapa (opcional)
    let legGeometry: LegGeometry

    struct LegGeometry: Decodable {
        let points: String
    }

    // Propiedad calculada para obtener el color de ruta como Color de SwiftUI
    var color: Color {
        guard let hex = routeColor, let uiColor = UIColor(hex: hex) else {
            // Color por defecto para caminar o modos sin color específico
            return mode == "WALK" ? .gray : .maasPrimary
        }
        return Color(uiColor)
    }

    // Propiedad calculada para obtener el icono SFSymbol correspondiente
    var icon: String {
        switch mode {
        case "WALK": return "figure.walk"
        case "BUS": return "bus.fill"
        case "TRAM": return "tram.fill"
        case "SUBWAY": return "train.subway.tunnel"
        default: return "point.fill"
        }
    }

    // Propiedad calculada para el nombre del segmento
    var segmentDescription: String {
        switch mode {
        case "WALK":
            let distanceKm = (distance / 1000.0).formatted(.number.precision(.fractionLength(2)))
            return "Caminar \(distanceKm) km hasta \(to.name ?? "destino")"
        case "BUS", "TRAM", "SUBWAY":
            let routeName = routeShortName ?? routeLongName ?? "Ruta sin nombre"
            return "Tomar \(routeName) desde \(from.name ?? "origen")"
        default:
            return "Viaje en \(mode)"
        }
    }
}

struct RouteStep: Identifiable {
    let id = UUID()
    let time: String
    let description: String
    let iconName: String
    let duration: String?
    let detailLines: [String] // Para detalles como transbordos o paradas
}

/// Estructura para simular el resultado completo de la ruta.
struct RouteResult {
    let startTime: String
    let endTime: String
    let totalDuration: String
    let steps: [RouteStep]
}

