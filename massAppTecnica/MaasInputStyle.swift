//
//  MaasInputStyle.swift
//  massAppTecnica
//
//  Created by Victor Manuel Blanco Mancera on 6/11/25.
//

import SwiftUI

// MARK: - Definiciones de Colores
extension Color {
    // Colores Principales del Branding MAAS/Tullave
    static let maasPrimary = Color(red: 0.40, green: 0.76, blue: 0.16) // Verde principal (Botón Continuar)
    static let maasDark = Color(red: 0.17, green: 0.20, blue: 0.22) // Negro/Gris oscuro para textos y títulos (Display Large)
    static let maasLightBackground = Color(red: 0.98, green: 0.98, blue: 0.96) // Fondo claro para inputs (Casi blanco/crema)
    static let maasBalanceBlue = Color(red: 0.38, green: 0.40, blue: 0.90) // Nuevo color azul/púrpura para el saldo
    static let maasSuccess = Color(red: 0.15, green: 0.53, blue: 0.14) // Tono de verde más oscuro (Hover)
    static let maasError = Color.red // Rojo estándar para errores
    static let tullaveCardGradientStart = Color(red: 0.50, green: 0.82, blue: 0.19) // Verde claro de la tarjeta
    static let tullaveCardGradientEnd = Color(red: 0.25, green: 0.65, blue: 0.15) // Verde oscuro de la tarjeta
}

// MARK: - Estilo de Texto (Usando la familia de fuentes Inter, que es la predeterminada en SwiftUI)
extension Font {
    static var headlineLarge: Font { .system(size: 24, weight: .bold) }
    static var headlineMedium: Font { .system(size: 20, weight: .semibold) }
    static var titleLarge: Font { .system(size: 18, weight: .semibold) }
    static var titleMedium: Font { .system(size: 16, weight: .medium) }
    static var bodyMedium: Font { .system(size: 14, weight: .regular) }
}

// MARK: - Estilo de Campo de Texto (Input)
struct MaasInputStyle: TextFieldStyle {
    var isError: Bool

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical, 12)
            .padding(.horizontal, 15)
            .background(Color.maasLightBackground) // Fondo crema del diseño
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isError ? Color.maasError : Color.gray.opacity(0.3), lineWidth: isError ? 1.5 : 1)
            )
    }
}
