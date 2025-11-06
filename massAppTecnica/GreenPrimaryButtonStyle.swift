//
//  GreenPrimaryButtonStyle.swift
//  massAppTecnica
//
//  Created by Victor Manuel Blanco Mancera on 6/11/25.
//

import SwiftUI

// MARK: - 1. Estilo de Botón Primario (Verde con Gradiente)

struct GreenPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, 12)
            .padding(.horizontal, 25)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(
                // Simular el gradiente del diseño (Estado Básico)
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 125/255, green: 204/255, blue: 67/255), // Verde claro
                                Color(red: 88/255, green: 177/255, blue: 50/255)  // Verde oscuro
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - 2. Campo de Entrada Personalizado

struct CardSerialInputField: View {
    @Binding var text: String
    @Binding var errorMessage: String?
    let placeholder: String
    
    // Calcula si hay un error para aplicar el estilo de borde
    private var hasError: Bool {
        errorMessage != nil && !errorMessage!.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            TextField(placeholder, text: $text)
                .keyboardType(.numberPad)
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background(Color.white) // Fondo blanco/crema simulado
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        // Borde azul si está activo (simulando enfoque) o rojo si hay error
                        .stroke(hasError ? Color.red : Color.gray.opacity(0.3), lineWidth: hasError ? 2 : 1)
                        .shadow(color: hasError ? Color.red.opacity(0.2) : Color.clear, radius: 4, x: 0, y: 2)
                )

            // Mensaje de error (Validación: Solo números)
            if hasError {
                Text(errorMessage ?? "Error")
                    .font(.caption)
                    .foregroundColor(.red)
                    .transition(.opacity)
            } else {
                Text("Solo se permiten caracteres numéricos.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
