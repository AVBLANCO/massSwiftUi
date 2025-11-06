//
//  TullaveCard.swift
//  massAppTecnica
//
//  Created by Victor Manuel Blanco Mancera on 5/11/25.
//
import Foundation
import SwiftData

// MARK: - SwiftData Model

/// Modelo de la Tarjeta Tullave para SwiftData
@Model
final class TullaveCard {
    var serial: String // ID único de la tarjeta
    var fullName: String
    var profile: String
    var isActive: Bool // Indica si es la tarjeta seleccionada actualmente
    var registeredDate: Date

    init(serial: String, fullName: String, profile: String, isActive: Bool = false) {
        self.serial = serial
        self.fullName = fullName
        self.profile = profile
        self.isActive = isActive
        self.registeredDate = Date()
    }

    // Función de conveniencia para crear desde la respuesta del API de Información de Tarjeta
    convenience init(from apiResponse: CardInformationAPIResponse, isActive: Bool = false) {
        // Mapeamos userName y userLastName a fullName
        let fullUserName = "\(apiResponse.userName) \(apiResponse.userLastName)"

        self.init(
            // El número de tarjeta (cardNumber) se mapea a nuestro campo serial
            serial: apiResponse.cardNumber,
            fullName: fullUserName,
            profile: apiResponse.profile,
            isActive: isActive
        )
    }
}
