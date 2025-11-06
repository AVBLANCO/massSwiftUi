//
//  NetworkManager.swift
//  massAppTecnica
//
//  Created by Victor Manuel Blanco Mancera on 5/11/25.
//

import Foundation
import CoreLocation
import MapKit

// MARK: - Errores de Red

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case authenticationFailed
    case decodingFailed(Error)
    case apiError(String)
    case generic(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "La URL de la API es inválida."
        case .invalidResponse: return "Respuesta de red inválida."
        // CORRECCIÓN: Mensaje actualizado para Bearer Token
        case .authenticationFailed: return "Error de autenticación. Verifique el token Bearer (JWT)."
        case .decodingFailed: return "Error al decodificar la respuesta de la API."
        case .apiError(let message): return message
        case .generic(let error): return error.localizedDescription
        }
    }
}

// MARK: - Network Manager

/// Manejador de la autenticación y las peticiones a la API de Tarjetas y OpenTripPlanner.
class NetworkManager {
    // NUEVO: Token JWT de ejemplo del Swagger para Bearer Token
    private let authToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJtYWFzIiwicHJpdmlsZWdlcyI6WyJDYXJkSW5mb3JtYXRpb25BY2Nlc3MiLCJSZWNoYXJnZUluZm9ybWF0aW9uQWNjZXNzIiwiUmVjaGFyZ2VDcmVhdGlvbkFjY2VzcyIsIlZTQU1SZWNoYXJnZXIiXSwiaXNzIjoicmJzYXMuY28iLCJjb21wYW55IjoiMTAwOCIsImV4cCI6MTc2MzQ3NTIwMSwiaWF0IjoxNzU4MjA0ODAxfQ.JSjxhto5B68HDRZsnA5uliDujEs1zyGJEfyn3cpEEu3VbY099hfhKwsJSXA93hFboQO0SO_8SYXPHmwmzjlUSDYb2OIZTiVOaVe5PXfxZeOpPrOcv_hwTtCumev0OGzWdloTShzw-PvfR3DmGpLM4WxJ5k_1yZ4j1SAKFdJeWTWSYbeH_M8NQDe6cv6rsEVOKRYu73EWoC2s7Ut7Wlf1rUz35Ljm6M_obLqAmOf35EQ7iCcmfBWjGO-BEFSi2BG2IxKYzMVXmtRxtcS5Yi-eoUxJ6nISNv6O7hRLRjgGpZhZoZWj4cqCF63SbgxAq_tzxLcJdvRSFT0cjkgHfITxSg"

    // CORRECCIÓN: URL base de la nueva API de Tarjetas (Swagger)
    private let cardAPIBaseURL = "https://osgqhdx2wf.execute-api.us-west-2.amazonaws.com"
    private let otpBaseURL = "https://sisuotp.tullaveplus.gov.co/otp/routers/default"


    // MARK: - Función de Petición Genérica (Bearer Token)

    /// Función genérica para ejecutar peticiones GET a la API de Tarjetas con autenticación Bearer Token.
    private func executeAPICall<T: Decodable>(path: String, serial: String, responseType: T.Type) async throws -> T {

        // 1. Construcción de URL (usando la nueva URL base)
        guard let url = URL(string: "\(cardAPIBaseURL)\(path)/\(serial)") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")

        // 2. Aplicar Bearer Token Authentication (JWT)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        // 3. Manejo de errores HTTP (incluyendo decodificación de APIErrorResponse)
        if !(200...299).contains(httpResponse.statusCode) {

            // Intenta decodificar el cuerpo de error de la API (APIErrorResponse)
            if let apiErrorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                // El error de la API contiene un mensaje específico
                throw NetworkError.apiError("\(apiErrorResponse.errorMessage) (Código: \(httpResponse.statusCode) - \(apiErrorResponse.errorCode))")
            } else if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                // Error de autenticación/prohibido
                 throw NetworkError.authenticationFailed
            } else {
                // Error genérico HTTP sin cuerpo de error decodificable
                throw NetworkError.apiError("Fallo en la petición con código HTTP: \(httpResponse.statusCode)")
            }
        }

        // 4. Decodificación
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch let decodingError {
            // El error de decodificación incluye el error original para debugging
            throw NetworkError.decodingFailed(decodingError)
        }
    }


    // MARK: - Servicios de Tarjeta (Swagger)

    /// Servicio 1: Valida si la tarjeta es válida y retorna su estado (GET /card/valid/{card}).
    func fetchCardStatus(serial: String) async throws -> CardStatusAPIResponse {
        return try await executeAPICall(path: "/card/valid", serial: serial, responseType: CardStatusAPIResponse.self)
    }

    /// Servicio 2: Obtiene la información del titular de la tarjeta (GET /card/getInformation/{card}).
    func fetchCardInformation(serial: String) async throws -> CardInformationAPIResponse {
        return try await executeAPICall(path: "/card/getInformation", serial: serial, responseType: CardInformationAPIResponse.self)
    }

    /// Servicio 3: Obtiene el balance de la tarjeta (GET /card/getBalance/{card}).
    func fetchCardBalance(serial: String) async throws -> CardBalanceAPIResponse {
        return try await executeAPICall(path: "/card/getBalance", serial: serial, responseType: CardBalanceAPIResponse.self)
    }


    // MARK: - OpenTripPlanner (Se mantiene)

    /// Busca paradas de OpenTripPlanner cerca de una ubicación (simulado con el requisito de 1000m).
    func fetchNearbyStops(latitude: Double, longitude: Double) async throws -> [MKPointAnnotation] {
        print("Buscando paraderos cerca de \(latitude), \(longitude) (max 1000m) - SIMULADO")
        // Retorna datos simulados con ubicaciones cercanas
        return [
            MKPointAnnotation(__coordinate: CLLocationCoordinate2D(latitude: latitude + 0.003, longitude: longitude + 0.001)),
            MKPointAnnotation(__coordinate: CLLocationCoordinate2D(latitude: latitude - 0.005, longitude: longitude - 0.002)),
            MKPointAnnotation(__coordinate: CLLocationCoordinate2D(latitude: latitude + 0.001, longitude: longitude - 0.004)),
        ]
    }
}
