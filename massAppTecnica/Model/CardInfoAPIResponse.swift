//
//  CardInfoAPIResponse.swift
//  massAppTecnica
//
//  Created by Victor Manuel Blanco Mancera on 5/11/25.
//

import Foundation
import SwiftData

// MARK: - API Errores Comunes
/// Estructura para decodificar el cuerpo de la respuesta cuando hay errores HTTP (4xx, 5xx).
struct APIErrorResponse: Codable {
    let errorCode: String
    let errorMessage: String
}

// MARK: - Servicio 1: /card/valid/{card} (Card Status)
/// Respuesta para la validación de la tarjeta.
struct CardStatusAPIResponse: Codable {
    let card: String
    let isValid: Bool
    let status: String
    let statusCode: Int
}

// MARK: - Servicio 2: /card/getInformation/{card} (Card Information)
/// Respuesta para la información del titular de la tarjeta.
struct CardInformationAPIResponse: Codable {
    let cardNumber: String
    let profileCode: String
    let profile: String
    // Usamos 'profile_es' como opcional ya que no está claro si siempre viene
    let profile_es: String?
    let bankCode: String
    let bankName: String
    let userName: String
    let userLastName: String
}

// MARK: - Servicio 3: /card/getBalance/{card} (Card Balance)
/// Respuesta para el balance de la tarjeta.
struct CardBalanceAPIResponse: Codable {
    let card: String
    let balance: Int
    let balanceDate: String
    let virtualBalance: Int
    let virtualBalanceDate: String
}

