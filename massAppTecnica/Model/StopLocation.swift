//
//  StopLocation.swift
//  massAppTecnica
//
//  Created by Victor Manuel Blanco Mancera on 6/11/25.
//

import Foundation
import SwiftData


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
}
