//
//  RoutePlannerViewModel.swift
//  massAppTecnica
//
//  Created by Victor Manuel Blanco Mancera on 6/11/25.
//

import Foundation
import Combine
import SwiftUI

class RoutePlannerViewModel: ObservableObject {

    // El router por defecto de la API de Sisú-OTP (normalmente es 'default')
    private let routerId = "default"
    // URL base de la API de OpenTripPlanner
    private let baseURL = "https://sisuotp.tullaveplus.gov.co/otp/routers/"

    @Published var originText: String = "4.6289,-74.0628" // Placeholder: Cerca de TransMilenio Av. 39
    @Published var destinationText: String = "4.6975,-74.0538" // Placeholder: Cerca de TransMilenio Calle 100
    @Published var currentRoute: RoutePlan?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Funcionalidad Principal: Obtener Plan de Ruta

    /// Realiza la solicitud a la API /plan de OpenTripPlanner para encontrar rutas óptimas.
    func findOptimalRoute() {
        self.isLoading = true
        self.errorMessage = nil
        self.currentRoute = nil

        // Validar que los campos de origen y destino no estén vacíos y contengan un formato de coordenada válido
        guard isValidCoordinateString(originText), isValidCoordinateString(destinationText) else {
            self.errorMessage = "Por favor, ingresa coordenadas válidas (lat,lon) para el origen y el destino."
            self.isLoading = false
            return
        }

        // Parámetros de la URL.
        // fromPlace: Origen (lat,lon)
        // toPlace: Destino (lat,lon)
        // date: Fecha actual (ej: 2025-11-06)
        // time: Hora actual (ej: 15:30)
        // mode: Modos de transporte (TRANSIT, WALK, BUS)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.string(from: Date())

        dateFormatter.dateFormat = "HH:mm"
        let timeString = dateFormatter.string(from: Date())

        let urlString = "\(baseURL)\(routerId)/plan?fromPlace=\(originText)&toPlace=\(destinationText)&date=\(dateString)&time=\(timeString)&mode=TRANSIT,WALK,BUS"

        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            self.errorMessage = "Error al construir la URL de la API."
            self.isLoading = false
            return
        }

        // Uso de Combine para la solicitud de red
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: RoutePlan.self, decoder: JSONDecoder.otpDecoder) // Usamos el Decodificador personalizado
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    print("Error de API: \(error.localizedDescription)")
                    self.errorMessage = "No se pudo planificar la ruta. Verifique las coordenadas y la disponibilidad del servicio."
                }
            }, receiveValue: { plan in
                self.currentRoute = plan
                print("Ruta planificada con éxito: \(plan.plan.itineraries.count) opciones encontradas.")
            })
            .store(in: &cancellables)
    }

    // Función auxiliar para validar el formato de lat, lon
    private func isValidCoordinateString(_ text: String) -> Bool {
        let components = text.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        guard components.count == 2,
              let lat = Double(components[0]),
              let lon = Double(components[1]) else {
            return false
        }
        // Validación básica de rango
        return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180
    }
}

// MARK: - Decodificador Personalizado para Fechas

// La API de OTP devuelve fechas en milisegundos (UNIX timestamp),
// así que necesitamos un Decodificador personalizado para manejar esto.
extension JSONDecoder {
    static var otpDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let timestamp = try container.decode(Double.self) / 1000.0 // Convertir de ms a segundos
            return Date(timeIntervalSince1970: timestamp)
        }
        return decoder
    }
}
